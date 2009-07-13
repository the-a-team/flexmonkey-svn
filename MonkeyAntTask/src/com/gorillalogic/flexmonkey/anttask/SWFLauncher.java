package com.gorillalogic.flexmonkey.anttask;

/**
 * Interface through which SWFs are launched.
 */
public interface SWFLauncher
{
   /**
    * Launch a SWF with the specified name.
    * 
    * @param swf name of SWF
    * @throws Exception if there is a problem launching the SWF
    */
   public void launch( String swf ) throws Exception;
}