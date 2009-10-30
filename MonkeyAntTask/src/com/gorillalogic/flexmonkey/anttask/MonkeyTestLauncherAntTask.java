package com.gorillalogic.flexmonkey.anttask;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.ServerSocket;
import java.net.Socket;
import java.net.SocketTimeoutException;
import java.text.MessageFormat;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.Task;
import org.dom4j.Document;
import org.dom4j.DocumentException;
import org.dom4j.DocumentHelper;
import org.dom4j.Element;
import org.dom4j.io.OutputFormat;
import org.dom4j.io.XMLWriter;

public class MonkeyTestLauncherAntTask extends Task
{
   private static final String REQUEST_PARAMS = "<requestParams/>";
   private static final String END_OF_TEST_RUN = "<endOfTestRun/>";
   private static final String END_OF_TEST_SUITE = "</testsuite>";
   private static final String END_OF_TEST_ACK = "<endOfTestRunAck/>";
   private static final char NULL_BYTE = '\u0000';
   private static final String FILENAME_PREFIX = "TEST-";
   private static final String FILENAME_EXTENSION = ".xml";

   private static final String NAME_ATTRIBUTE = "@name";
   private static final String FAILURES_ATTRIBUTE = "@failures";
   private static final String ERRORS_ATTRIBUTE = "@errors";
   private static final String TESTS_ATTRIBUTE = "@tests";
   private static final String TIME_ATTRIBUTE = "@time";

   private static final String POLICY_FILE_REQUEST = "<policy-file-request/>";
   private static final String DOMAIN_POLICY = "<cross-domain-policy><allow-access-from domain=\"*\" to-ports=\"{0}\" /></cross-domain-policy>";

   private static final String TRUE = "true";

   // Verbose messages
   private static final String END_OF_TEST = "End of test";
   private static final String SENT_POLICY = "Sent policy file";
   private static final String TEST_INFO = "Tests run: {0}, Failures: {1}, Errors: {2}, Time Elapsed: {3} sec";

   // Exception messages
   private static final String FAILED_TEST = "FlexUnit test {0} failed.";
   private static final String ERROR_PARSING_REPORT = "Error parsing report.";
   private static final String ERROR_SAVING_REPORT = "Error saving report.";

   private boolean complete = false;
   private BuildException threadException;
   private boolean verbose = true;

   // attributes from ant task def
   private int port = 1024;
   private int socketTimeout = 60000; // milliseconds
   private boolean failOnTestFailure = false;
   private String failureProperty = "flexunit.failed";
   private String launcher;
   private String targetSwf;
   private String testModuleSwf;
   private String snapshotDir;
   private File reportDir;

   /**
    * Set the port to receive the test results on.
    * 
    * @param serverPort
    *           the port to set.
    */
   public void setPort( final int serverPort )
   {
      port = serverPort;
   }

   /**
    * Set the timeout for receiving the flexunit report.
    * 
    * @param timeout
    *           in milliseconds.
    */
   public void setTimeout( final int timeout )
   {
      socketTimeout = timeout;
   }
   
   /**
    * The launcher URL (usually points to MonkeyTestLauncher.html)
    * 
    * @param url
    *           the launcher URL.
    */
   public void setLauncher( final String url )
   {
	   launcher = url;
   }

   /**
    * The SWF for application under test.
    * 
    * @param swf
    *           the name of the SWF.
    */
   public void setTargetSwf( final String swf )
   {
	   targetSwf = swf;
   }
   
   /**
    * The test module SWF.
    * 
    * @param swf
    *           the name of the SWF.
    */
   public void setTestModuleSwf( final String swf )
   {
	   testModuleSwf = swf;
   }
   
   /**
    * The test module SWF.
    * 
    * @param dir
    *           the name of the SWF.
    */
   public void setSnapshotDir( final String dir )
   {
	   snapshotDir = dir;
   }

   /**
    * Set the directory to output the test reports to.
    * 
    * @param toDir
    *           the directory to set.
    */
   public void setToDir( final String toDir )
   {
      reportDir = new File( toDir );
   }

   /**
    * Should we fail the build if the flex tests fail?
    * 
    * @param fail
    */
   public void setHaltonfailure( final boolean fail )
   {
      failOnTestFailure = fail;
   }

   /**
    * Custom ant property noting test failure
    * 
    * @param failprop
    */
   public void setFailureproperty( final String failprop )
   {
      failureProperty = failprop;
   }

   /**
    * Custom ant property noting test failure
    * 
    * @param verbose
    */
   public void setVerbose( final boolean verbose )
   {
      this.verbose = verbose;
   }

   /**
    * Called by Ant to execute the task.
    */
   public void execute() throws BuildException
   {
      // Check a SWF was specified.
      if ( launcher == null || launcher.length() == 0 )
      {
         throw new BuildException( "You must specify the 'launcher' property." );
      }

      createReportDirectory();

      setupClientConnection();

      launchTestSuite();

      waitForTestSuiteToExcecute();
   }

   private void waitForTestSuiteToExcecute()
   {
      while ( !complete )
      {
         try
         {
            Thread.sleep( 1000 );
         }
         catch ( InterruptedException e )
         {
            throw new BuildException( e );
         }
      }

      if ( threadException != null )
      {
         if ( verbose )
         {
            log( "Error running test suite: " + threadException.getMessage() );
         }

         throw threadException;
      }
   }

   private void launchTestSuite()
   {
      final FlexUnitLauncher browser = new FlexUnitLauncher();

      try
      {
         browser.runTests( launcher );
      }
      catch ( Exception e )
      {
//         throw new BuildException( "Error launching the test runner.", e );
      }
   }

   private void createReportDirectory()
   {
      if ( reportDir == null )
      {
         reportDir = getProject().resolveFile( "." );
      }

      reportDir.mkdirs();
   }

   /**
    * Create a server socket for receiving the test reports from FlexUnit. We
    * read the test reports inside of a Thread.
    */
   private void setupClientConnection()
   {
      // Start a thread to accept a client connection.
      final Thread thread = new Thread()
      {
         private ServerSocket serverSocket = null;
         private Socket clientSocket = null;
         private InputStream in = null;
         private OutputStream out = null;

         public void run()
         {
            try
            {
               openServerSocket();
               openClientSocket();
               handleClientConnection();
            }
            catch ( BuildException buildException )
            {
               threadException = buildException;

               try
               {
                  sendAcknowledgement();
               }
               catch ( IOException e )
               {
                  // ignore
               }
            }
            catch ( SocketTimeoutException e )
            {
               threadException = new BuildException(
                     "Socket timeout waiting for flexunit report", e );
            }
            catch ( IOException e )
            {
               //throw new RuntimeException("Got IOException: " + e);
               threadException = new BuildException(
                     "Error receiving report from flexunit", e );
            }
            finally
            {
               // always stop the server loop
               complete = true;

               closeClientSocket();
               closeServerSocket();
            }
         }

         private void handleClientConnection() throws IOException
         {
            StringBuffer buffer = new StringBuffer();
            int bite = -1;

            while ( ( bite = in.read() ) != -1 )
            {
               final char chr = ( char ) bite;

               if ( chr == NULL_BYTE )
               {
                  final String data = buffer.toString();
                  buffer = new StringBuffer();
                  if ( data.equals( REQUEST_PARAMS ) )
                  {
                     sendParameters();
                  }
                  else if ( data.equals( POLICY_FILE_REQUEST ) )
                  {
                     sendPolicyFile();
                     closeClientSocket();
                     openClientSocket();
                  }
                  else if ( data.endsWith( END_OF_TEST_SUITE ) )
                  {
                     processTestReport( data );
                  }
                  else if ( data.equals( END_OF_TEST_RUN ) )
                  {
                     sendAcknowledgement();
                     ProcessHolder.getInstance().process.destroy();
                  }
               }
               else
               {
                  buffer.append( chr );
               }
            }
         }
         

         private void sendParameters() throws IOException
         {
            if ( verbose )
            {
               log( "Sending parameters: targetSwf=" + targetSwf + ", testModuleSwf=" + testModuleSwf  );
            }
            String xml = "<parameters targetSwf=\"" + targetSwf + "\" testModuleSwf=\"" + testModuleSwf + "\" snapshotDir=\"" + snapshotDir + "\"/>";
            out.write( xml.getBytes() );
            out.write( NULL_BYTE );
         }

         private void sendPolicyFile() throws IOException
         {
            out.write( MessageFormat.format( DOMAIN_POLICY, new Object[]
            { Integer.toString( port ) } ).getBytes() );

            out.write( NULL_BYTE );

            if ( verbose )
            {
               log( SENT_POLICY );
            }
         }

         private void processTestReport( final String report )
         {
            writeTestReport( report );

            if ( verbose )
            {
               log( END_OF_TEST );
            }
         }

         private void sendAcknowledgement() throws IOException
         {
            out.write( END_OF_TEST_ACK.getBytes() );
            out.write( NULL_BYTE );
         }

         private void openServerSocket() throws IOException
         {
            serverSocket = new ServerSocket( port );
            serverSocket.setSoTimeout( socketTimeout );

            if ( verbose )
            {
               log( "Opened server socket" );
            }
         }

         private void closeServerSocket()
         {
            if ( serverSocket != null )
            {
               try
               {
                  serverSocket.close();
               }
               catch ( IOException e )
               {
                  // ignore
               }
            }
         }

         private void openClientSocket() throws IOException
         {
            // This method blocks until a connection is made.
            clientSocket = serverSocket.accept();

            if ( verbose )
            {
               log( "Accepting data from client" );
            }

            in = clientSocket.getInputStream();
            out = clientSocket.getOutputStream();
         }

         private void closeClientSocket()
         {
            // Close the output stream.
            if ( out != null )
            {
               try
               {
                  out.close();
               }
               catch ( IOException e )
               {
                  // ignore
               }
            }

            // Close the input stream.
            if ( in != null )
            {
               try
               {
                  in.close();
               }
               catch ( IOException e )
               {
                  // ignore
               }
            }

            // Close the client socket.
            if ( clientSocket != null )
            {
               try
               {
                  clientSocket.close();
               }
               catch ( IOException e )
               {
                  // ignore
               }
            }
         }
      };

      thread.start();
   }

   protected void writeTestReport( final String report )
   {
      final Document document = parseReport( report );

      final Element root = document.getRootElement();
      final String name = root.valueOf( NAME_ATTRIBUTE );

      final int failures = Integer
            .parseInt( root.valueOf( FAILURES_ATTRIBUTE ) );
      final int errors = Integer.parseInt( root.valueOf( ERRORS_ATTRIBUTE ) );

      saveTestReportToFile( document, name );

      checkForErrors( name, failures, errors );
   }

   private void checkForErrors( final String name, final int failures,
         final int errors )
   {
      if ( failures > 0 || errors > 0 )
      {
         getProject().setNewProperty( failureProperty, TRUE );

         final String message = MessageFormat.format( FAILED_TEST, new Object[]
         { name } );

         if ( verbose )
         {
            log( message );
         }

         if ( failOnTestFailure )
         {
            throw new BuildException( message );
         }
      }
   }

   private Document parseReport( final String report )
   {
      try
      {
         final Document document = DocumentHelper.parseText( report );

         if ( verbose )
         {
            log( formatLogReport( document ) );
         }

         return document;
      }
      catch ( DocumentException e )
      {
         throw new BuildException( ERROR_PARSING_REPORT, e );
      }
   }

   private void saveTestReportToFile( final Document report, final String name )
   {
      try
      {
         final File file = new File( reportDir, FILENAME_PREFIX + name
               + FILENAME_EXTENSION );

         final OutputFormat format = OutputFormat.createPrettyPrint();
         final XMLWriter writer = new XMLWriter( new FileOutputStream( file ),
               format );
         writer.write( report );
         writer.close();
      }
      catch ( Exception e )
      {
         throw new BuildException( ERROR_SAVING_REPORT, e );
      }
   }

   private String formatLogReport( final Document document )
   {
      final Element root = document.getRootElement();
      final int numFailures = Integer.parseInt( root
            .valueOf( FAILURES_ATTRIBUTE ) );
      final int numErrors = Integer.parseInt( root.valueOf( ERRORS_ATTRIBUTE ) );
      final int numTests = Integer.parseInt( root.valueOf( TESTS_ATTRIBUTE ) );
      final float time = Float.parseFloat( root.valueOf( TIME_ATTRIBUTE ) );

      return MessageFormat.format( TEST_INFO, new Object[]
      { new Integer( numTests ), new Integer( numFailures ),
            new Integer( numErrors ), new Float( time ) } );
   }

   public void log( final String message )
   {
      System.out.println( message );
   }
}