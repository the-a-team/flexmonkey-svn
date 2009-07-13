package com.gorillalogic.flexmonkey.anttask;

/**
 * Launches a SWF on Windows.
 */
public class WindowsSWFLauncher implements SWFLauncher
{
   private static final String WINDOWS_CMD =
      "rundll32 url.dll,FileProtocolHandler ";

   public void launch( String swf ) throws Exception
   {
      swf = swf.replace( '/', '\\' );
      
      // Ideally we want to launch the SWF in the player so we can close
      // it, not so easy in a browser. We let 'rundll32' do the work based
      // on the extension of the file passed in.
      String execCmd = WINDOWS_CMD + swf;
      System.out.println("Invoking runner with command: " + execCmd);
      Runtime.getRuntime().exec( WINDOWS_CMD + swf );
   }
}
