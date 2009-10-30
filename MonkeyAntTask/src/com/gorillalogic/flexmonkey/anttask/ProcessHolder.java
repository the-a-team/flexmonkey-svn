package com.gorillalogic.flexmonkey.anttask;

public class ProcessHolder {
	private static ProcessHolder instance = null;
	
	public Process process = null;
	
	protected ProcessHolder(){
		// defeats instantiation
	}
	
	public static ProcessHolder getInstance(){
		if(instance == null){
			instance = new ProcessHolder();
		}
		return instance;
	}
	
}
