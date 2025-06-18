package codeql.template

import util.StringUtilities

class Metadata {
	
	def static CharSequence generateHeader(String name, String kind, String severity, String id)
	'''
	/**
	 * This is an automatically generated file
	 *
	 * @name «name»
	 * @kind «kind»
	 * @problem.severity «severity»
	 * @id «id»
	 */
	 
	'''
	
	def static CharSequence generateCodeQLPack(String name)
	'''
	# This is an automatically generated file.
	name: «StringUtilities.replaceUnderscoreWithDash(name.toLowerCase)»-queries
	version: 0.0.0
	dependencies:
	  codeql/java-all: "*"
	extractor: java
	'''
	
	def static CharSequence generateSuite(String name)
	'''
	- description: «name»
	- queries: .
	'''
	
}