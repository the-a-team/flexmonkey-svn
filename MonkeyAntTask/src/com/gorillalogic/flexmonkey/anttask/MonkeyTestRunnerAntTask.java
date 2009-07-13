package com.gorillalogic.flexmonkey.anttask;

import java.io.File;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.Vector;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.DirectoryScanner;
import org.apache.tools.ant.Task;
import org.apache.tools.ant.taskdefs.Execute;
import org.apache.tools.ant.types.Commandline;
import org.apache.tools.ant.types.FileSet;


public class MonkeyTestRunnerAntTask extends Task {
	// private static final String WINDOWS_CMD = "rundll32
	// url.dll,FileProtocolHandler ";
	// private static final String UNIX_CMD = "gflashplayer ";
	// private static final String MAC_CMD = "open ";
	private String testRunnerSWF;
	private String targetSwf;
	private String snapshotDir;
	private String outputDir;
	private Boolean headless = true;
	private Boolean xvfb = false;
	private Boolean failOnError = true;
	private Vector<FileSet> filesets = new Vector<FileSet>();
	private File outputDirFile;

	public boolean debug = false;
	protected Commandline cmdl;

	public boolean isDebug()
	{
		return this.debug;
	}

	public void setDebug(boolean debug)
	{
		this.debug = debug;
	}

	public Boolean getHeadless()
	{
		return this.headless;
	}

	public void setHeadless(Boolean headless)
	{
		this.headless = headless;
	}

	public Boolean getFailonerror()
	{
		return this.failOnError;
	}

	public void setFailonerror(Boolean failonerror)
	{
		this.failOnError = failonerror;
	}

	public Boolean getXvfb() {
		return this.xvfb;
	}

	public void setXvfb(Boolean xvfb) {
		this.xvfb = xvfb;
	}

	public String getTestRunner()
	{
		return this.testRunnerSWF;
	}

	public void setTestRunner(String testRunnerSWF)
	{
		this.testRunnerSWF = testRunnerSWF;
	}


	public String getTargetSwf()
	{
		return this.targetSwf;
	}

	public void setTargetSwf(String targetSwf)
	{
		this.targetSwf = targetSwf;
	}


	public String getSnapshotDir()
	{
		return this.snapshotDir;
	}

	public void setSnapshotDir(String snapshotDir)
	{
		this.snapshotDir = snapshotDir;
	}

	public String getOutputDir()
	{
		return this.outputDir;
	}

	public void setOutputDir(String dir)
	{
		this.outputDir = dir;
		// make sure the folder exists.
		this.outputDirFile = this.getProject().resolveFile(dir);
		if (!this.outputDirFile.exists())
		{
			this.outputDirFile.mkdir();
		}
	}

	public void addFileSet(FileSet fileset)
	{
		this.filesets.add(fileset);
	}

	private String[] prepareArguments()
	{
		ArrayList<String> args = new ArrayList<String>();
		
		String[] includedFiles = null;
		String[] resolvedFiles = null;
		if (this.filesets != null && this.filesets.size() > 0)
		{
			for (Iterator<FileSet> itFSets = this.filesets.iterator(); itFSets
					.hasNext();)
			{
				FileSet fs = itFSets.next();
				DirectoryScanner ds = fs.getDirectoryScanner();
				includedFiles = ds.getIncludedFiles();
				resolvedFiles = new String[includedFiles.length];

				for (int i = 0; i < includedFiles.length; i++)
				{
					String filename = includedFiles[i].replace('\\', '/');
					filename = filename
							.substring(filename.lastIndexOf("/") + 1);
					File base = ds.getBasedir();
					File found = new File(base, includedFiles[i]);
					resolvedFiles[i] = found.getAbsolutePath();
				}
			}
		}
		
		if(this.xvfb && this.headless)
		{
			//make sure the flag to automagically find a display is set first
			args.add(0, "-a");

			//verify path is Linux savvy (will NOT work with paths containing spaces - '\ ' will be converted to '/ ')
			//add as 2nd parameter
			args.add(1, this.testRunnerSWF.replace('\\', '/'));
		}

		if (this.headless)
		{
			args.add("-headless");
		}

		if(this.failOnError)
		{
			args.add("-failOnError");
		}
		
		args.add("-targetSwf='" + this.targetSwf + "'");	
		args.add("-snapshotDir='" + this.snapshotDir + "'");		
		args.add("-reportDir='" + this.outputDir + "'");
		
		if (resolvedFiles != null && resolvedFiles.length > 0)
		{
			StringBuffer fileList = new StringBuffer();
			fileList.append("-fileSet='");

			for (int x = 0; x < resolvedFiles.length; x++)
			{
				if (x != 0)
				{
					fileList.append(",");
				}
				fileList.append(resolvedFiles[x]);
			}

			fileList.append("'");

			args.add(fileList.toString());
		}
		
		
		String[] str = new String[args.size()];
		
		return args.toArray(str);
		
	}

	private Execute prepareTestRunnerExecute()
	{
		this.testRunnerSWF = this.testRunnerSWF.replace('/', '\\');

		this.cmdl = new Commandline();

		String executable = null;

		if(this.xvfb && this.headless)
		{
			executable = "xvfb-run";
		}
		else
		{
			executable = this.testRunnerSWF;
		}

		this.cmdl.setExecutable(executable);
		this.cmdl.addArguments(this.prepareArguments());

		Execute exe = new Execute();
		exe.setAntRun(this.getProject());
		exe.setCommandline(this.cmdl.getCommandline());

		return exe;
	}

	@Override
	public void execute()
	{
		// todo: check and throw exception if no swf was defined
		Execute exe = this.prepareTestRunnerExecute();

		System.out.println("Using '" + exe.getWorkingDirectory().getAbsolutePath() + "' as working directory.");

		try
		{
			int returnValue = exe.execute();

			if (this.isDebug())
			{
				System.out.println("DEBUG: " + this.cmdl.describeCommand());
				System.out.println("DEBUG: " + returnValue );
			}

			if(returnValue != 0 && this.failOnError)
			{
				throw new Exception("Test(s) failed, please see report in '" + this.outputDirFile.getAbsolutePath() + "' for more details ...'");
			}
		}
		catch (Exception e)
		{
			throw new BuildException("FAILED: " + e.getMessage(), e);
		}
	}

}
