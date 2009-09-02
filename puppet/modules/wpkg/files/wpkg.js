/** Version as it appears within the log file */
var WPKG_VERSION = "1.1.1";
/*******************************************************************************
 *
 * WPKG - Windows Packager
 * Copyright 2003 Jerry Haltom
 * Copyright 2005 Aleksander Wysocki <papopypu (at) op . pl>
 * Copyright 2005-2006 Tomasz Chmielewski <mangoo (at) wpkg . org>
 * Copyright 2007-2009 Rainer Meier <r.meier (at) wpkg.org>
 *
 * Please report your issues to the list on http://wpkg.org/
 */

/**
 * Displays command usage.
 */
function showUsage() {
var message = "" +
"If you cannot read this since it is displayed within a dialog-window please \n" +
"execute 'cscript wpkg.js /help' on the command line. This will print all \n" + 
"messages to the console. \n\n" + 
"Command Line Switches \n" + 
"===================== \n" + 
"Note: These command line switches overwrite parameters within config.xml. For \n" + 
"example the /quiet flag overwrites an eventually present quiet parameter within \n" + 
"config.xml. \n" + 
"Usually you should specify as few parameters as possible since changing \n" + 
"config.xml on the server might be much easier than changing all client-side \n" + 
"stored parameters. Typically you would use the following command-line in \n" + 
"production: \n" + 
"	wpkg.js /synchronize \n" + 
"\n" + 
"Frequently used parameters (package operations, you need to choose one): \n" + 
"======================================================================== \n" + 
"\n" + 
"/install:<package> \n" + 
"	Install the specified package on the system. \n" + 
"\n" + 
"/query:<option> \n" + 
"	Display a list of packages matching the specified criteria. Valid \n" + 
"	options are: \n" + 
"\n" + 
"	a - all packages \n" + 
"	i - packages that are currently installed on the system \n" + 
"	x - packages that are currently not installed on the system \n" + 
"	u - packages that can be upgraded \n" + 
"\n" + 
"/remove:<package> \n" + 
"	Remove the specified package from the system. \n" + 
"\n" + 
"/show:<package> \n" + 
"	Display a summary of the specified package, including it's state. \n" + 
"\n" + 
"/upgrade:<package> \n" + 
"	Upgrade the already installed package on the system. \n" + 
"\n" + 
"/synchronize \n" + 
"	Synchronize the current program state with the suggested program state \n" + 
"	of the specified profile. This is the action that should be called at \n" + 
"	system boot time for this program to be useful. \n" + 
"\n" + 
"/help \n" + 
"	Show this message. \n" + 
"\n" + 
"\n" + 
"Optional parameters (usually defined within config.xml): \n" + 
"======================================================== \n" + 
"\n" + 
"/base:<path> \n" + 
"	Set the local or remote path to find the xml input files. \n" + 
"	Can also be set to a web URL for direct XML retrieval from wpkg_web. \n" + 
"\n" + 
"/dryrun \n" + 
"	Do not execute any actions. Implicites /debug. \n" + 
"\n" + 
"/quiet \n" + 
"	Use the event log to record all error/status messages. Use this when \n" + 
"	running unattended. \n" + 
"\n" + 
"/nonotify \n" + 
"	Logged in users are not notified about impending updates. \n" + 
"\n" + 
"/noreboot \n" + 
"	System does not reboot regardless of need. \n" + 
"\n" + 
"/quitonerror \n" + 
"	Quit execution if the installation of any package was unsuccessful \n" + 
"	(default: install next package and show the error summary). \n" + 
"\n" + 
"/sendStatus \n" + 
"	Send status messages on STDOUT which can be parsed by calling programm to \n" + 
"	display status information to the user. \n" + 
"\n" + 
"/noUpgradeBeforeRemove \n" +
"   Usually WPKG upgrades a package to the latest available version before it \n" +
"   removes the package. This allows administrators to fix bugs in the package \n" +
"   and assure proper removal.\n" +
"\n" + 
"\n" + 
"Rarely used parameters (mainly for testing): \n" + 
"============================================ \n" + 
"\n" + 
"/config:<path> \n" + 
"	Path to the configuration file to be used. The path might be absolute \n" + 
"	or relative but including the XML file name. This parameter is entirely \n" + 
"	OPTIONAL and should normally not be specified at all. \n" + 
"	If not specified the configuration will be searched at: \n" + 
"	<script-path>\\config.xml \n" + 
"	where <script-path> is the directory from which the script is executed. \n" + 
"		e.g. '\\\\server\\share\\directory\\config.xml'. \n" + 
"		e.g. 'directory\\config.xml'. \n" + 
"\n" + 
"/debug or /verbose \n" + 
"	Enable debug output. Please note that this parameter only influences \n" + 
"	notification and event log output. It does not affect the logging level. \n" + 
"	It is possible to get debug-level output even without using this \n" + 
"	switch. \n" + 
"\n" + 
"/force \n" + 
"	When used in conjunction with /synchronize WPKG will ignore the local \n" + 
"	settings file (wpkg.xml) and re-build the database with installed \n" + 
"	packages. \n" + 
"	When used in conjunction with /remove forces removal of the specified \n" + 
"	package even if not all packages which depend on the one to be removed \n" + 
"	could be removed. \n" + 
"\n" + 
"/forceinstall \n" + 
"	Force installation over existing packages. \n" + 
"\n" + 
"/host:<hostname> \n" + 
"	Use the specified hostname. This option is for testing purposes \n" + 
"	to test if a given hostname gets the correct profile assigned. \n" + 
"\n" + 
"/ignoreCase\n" + 
"	Disable case sensitivity of packages and profiles. Therefore you can\n" + 
"	assign the package 'myapp' to a profile while only a package 'MyApp' is\n" + 
"	defined within the packages.\n" + 
"	Note that this change requires modification of the package/profile/host nodes\n" + 
"	read from the XML files. All IDs are converted to lowercase.\n" + 
"	Note: This requires converting all profile/package IDs to lowercase.\n" + 
"		  Therefore you will only see lowercase entries within the log files\n" + 
"		  and also within the local package database.\n" + 
"\n" + 
"/logAppend \n" + 
"	Append log files instead of overwriting existing files. \n" + 
"	NOTE: You can specify a log file pattern which will create a new file on \n" + 
"	each run. Appending logs might cause problems with some log rotation \n" + 
"	scripts as well. So use it with caution. \n" + 
"\n" + 
"/logfilePattern:<pattern> \n" + 
"	Pattern for log file naming: \n" + 
"	Recognized patterns: \n" + 
"	 [HOSTNAME]  replaced by the executing hostname \n" + 
"	 [PROFILE]   replaced by the  name \n" + 
"	 [YYYY]      replaced by year (4 digits) \n" + 
"	 [MM]        replaced by month number (2 digits) \n" + 
"	 [DD]        replaced by the day of the month (2 digits) \n" + 
"	 [hh]        replaced by hour of the day (24h format, 2 digits) \n" + 
"	 [mm]        replaced by minutes (2 digits) \n" + 
"	 [ss]        replaced by seconds (2 digits) \n" + 
"\n" + 
"	 Examples: \n" + 
"	 'wpkg-[YYYY]-[MM]-[DD]-[HOSTNAME].log' \n" + 
"			 results in a name like 'wpkg-2007-11-04-myhost.log' \n" + 
"	NOTE: Using [PROFILE] causes all log messages before reading profiles.xml \n" + 
"			to be temporarily written to local %TEMP% folder. So they might \n" + 
"			appear on the final log file with some delay. \n" + 
"\n" + 
"/logLevel:[0-31] \n" + 
"	Level of detail for log file: \n" + 
"	use the following values: \n" + 
"	Log level is defined as a bitmask. Just sum up the values of each log \n" + 
"	severity you would like to include within the log file and add this value \n" + 
"	to your config.xml or specify it at /logLevel:<#>. \n" + 
"	Specify 0 to disable logging. \n" + 
"	  1: log errors only \n" + 
"	  2: log warnings \n" + 
"	  4: log information \n" + 
"	  8: log audit success \n" + 
"	 16: log audit failure \n" + 
"	Example: \n" + 
"	 31 log everything (1+2+4+8+16=31) \n" + 
"	 13 log errors, information and audit success (1+4+8=13) \n" + 
"	  3 log errors and warnings only (1+2=3) \n" + 
"	Default is 0 which will suppress all messages printed before log level is \n" + 
"	properly initialized by config.xml or by /logLevel:<#> parameter. \n" + 
"\n" + 
"/log_file_path:<path> \n" + 
"	Path where the log files will be stored. Also allows specifying an UNC \n" + 
"	path (e.g. '\\server\share\directory'). Make sure the path exists and \n" + 
"	that the executing user has write access to it. \n" + 
"	NOTE: If you set this parameter within config.xml please note that you \n" + 
"			need to escape backslashes: \n" + 
"			e.g. '\\\\server\\share\\directory'. \n" + 
"\n" + 
"/noforcedremove \n" + 
"	Do not remove packages from local package database if remove fails even \n" + 
"	if the package does not exist in the package database on the server and \n" + 
"	is not referenced within the profile. \n" + 
"	By default packages which have been removed from the server package \n" + 
"	database and the profile will be uninstalled and then removed \n" + 
"	from the local package database even if uninstall failed. \n" + 
"	This has been introduced to prevent a package whose uninstall script \n" + 
"	fails to repeat its uninstall procedure on each execution without the \n" + 
"	possibility to fix the problem since the package (including its \n" + 
"	uninstall string) is available on the local machine only. \n" + 
"	HINT: If you like the package to stay in the local database (including \n" + 
"	uninstall-retry on next boot) just remove it from the profile but do not \n" + 
"	completely delete it from the package database. \n" + 
"\n" + 
"/noremove \n" + 
"	Disable the removal of all packages. If used in conjunction with the \n" + 
"	/synchronize parameter it will just add packages but never remove them. \n" + 
"	Instead of removing a list of packages which would have been removed \n" + 
"	during that session is printed on exit. Packages are not removed from \n" + 
"	the local settings database (wpkg.xml). Therefore it will contain a list \n" + 
"	of all packages ever installed. \n" + 
"	Note that each package which is requested to be removed (manually or by \n" + 
"	a synchronization request) will be checked for its state by executing its \n" + 
"	included package checks. If the package has been removed manually it will \n" + 
"	also be removed from the settings database. Due to the fact that packages \n" + 
"	whithout checks always return 'false' for during the install-status check \n" + 
"	these packages will disappear from the local wpkg.xml. \n" + 
"\n" + 
"/norunningstate \n" + 
"	Do not export the running state to the registry. \n" + 
"\n" + 
"/profile:<profile> \n" + 
"	Force the name of the profile to use. If not specified, the profile to use \n" + 
"	is looked up in hosts.xml. \n" + 
"\n" + 
"/rebootcmd:<option> \n" + 
"	Use the specified boot command, either with full path or \n" + 
"	relative to the location of wpkg.js \n" + 
"	Specifying 'special' as option uses tools\psshutdown.exe \n" + 
"	from www.sysinternals.com - if it exists - and a notification loop \n";

	alert(message);
}

/*******************************************************************************
 *
 * Global variables
 *
 ******************************************************************************/
/** base where to find the XML input files */
var wpkg_base = "";

/** forces to check for package existence but ignores wpkg.xml */
var force = false;

/** force installation */
var forceInstall = false;

/* Forced remove of non-existing packages from wpkg.xml even if uninstall
 * command fails.
 */
var noForcedRemove = false;

/** defined if script should quit on error */
var quitonerror = false;

/** Debug output. */
var debug = false;

/** Dry run */
var dryrun = false;

/** notify user using net send? */
var nonotify = false;

/** set to true to prevent reboot */
var noreboot = false;

/** stores if package removal should be skipped - see /noremove flag */
var noRemove = false;

/** allows disabling/enabling of running state export to registry */
var noRunningState = false;

/** type of reboot command */
var rebootCmd = "standard";

/** set to true for quiet mode */
var quietDefault = false;

/** registry path where WPKG stores its running state */
var sRegWPKG_Running = "HKLM\\Software\\WPKG\\running";

/** config file to hold the settings for the script */
var config_file_name = "config.xml";

/** name of package database file */
var packages_file_name = "packages.xml";
/** name of profiles database file */
var profiles_file_name = "profiles.xml";
/** name of hosts definitnion database file */
var hosts_file_name = "hosts.xml";

/** specify if manually installed packages should be kept during synchronization
 * true:  keep manually installed packages
 * false: remove any manually installed package which does not belong to the profile
 */
var keepManual = true;

/** path where log-files are stored
 * Defaults to "%TEMP%" if empty.
 */
var log_file_path = "%TEMP%";

/** path where downloads are stored, defaults to %TEMP% if not defined */
var downloadDir = "%TEMP%";

/** timeout for downloads */
var downloadTimeout = 7200;

/** if set to true logfiles will be appended, otherwise they are overwritten */
var logAppend = false;

/**
 * set to true to enable sending of status messages to STDOUT, regardless of
 * the status of /debug
 */
var sendStatus = false;

/**
 * Set to true to disable upgrade-before-remove feature by default
 */
var noUpgradeBeforeRemove = false;

/** use the following values:
 * Log level is defined as a bitmask. Just add sum up the values of each log
 * severity you would like to include within the log file and add this value
 * to your config.xml or specify it at /logLevel:<num>.
 * Specify 0 to disable logging.
 * 1 : log errors only
 * 2 : log warnings
 * 4 : log information
 * 8 : log audit success
 * 16: log audit failure
 * Example:
 *     31 log everything (1+2+4+8+16=32)
 *     13 logs errors, information and audit success (1+4+8=13)
 *      3 logs errors and warnings only (1+2=3)
 * Default is 0 which will suppress all messages printed before log level is
 * properly initialized by config.xml or by /logLevel:<#> parameter.
 */
var logLevelDefault = 0xFF;

/** var logfile pattern
 * Recognized patterns:
 * [HOSTNAME]	replaced by the executing hostname
 * [PROFILE]	replaced by the  name
 * [YYYY]		replaced by year (4 digits)
 * [MM]			replaced by month number (2 digits)
 * [DD]			replaced by the day of the month (2 digits)
 * [HH]			replaced by hour of the day (24h format, 2 digits)
 * [mm]			replaced by minute (2 digits)
 *
 * Examples:
 * "wpkg-[YYYY]-[MM]-[DD]-[HOSTNAME].log"
 * 		results in a name like "wpkg-2007-11-04-myhost.log"
 */
var logfilePattern = "wpkg-[HOSTNAME].log";

/** web file name of package database if base is an http url */
var web_packages_file_name = "packages_xml_out.php";
/** web file name of profile database if base is an http url */
var web_profiles_file_name = "profiles_xml_out.php";
/** web file name of hosts database if base is an http url */
var web_hosts_file_name = "hosts_xml_out.php";

/** name of local settings file */
var settings_file_name = "wpkg.xml";

/** path to settings file, defaults to system folder if set to null */
var settings_file_path = null;

/** defines if package/profile IDs are handled case sensitively */
var caseSensitivity = true;

/*******************************************************************************
 *
 * Caching variables - used by internal functions.
 *
 ******************************************************************************/

// Save the old environment.
var oldEnv = new ActiveXObject("Scripting.Dictionary");

/** file to which the log is written to */
var logfileHandler = null;

/** path to the log file (corresponds to logfileHandler) */
var logfilePath = null;

/** stores if the user was notified about start of actions */
var was_notified = false;

/** holds a list of packages which have been installed during this execution
 * this is used to prevent dependency packages without checks and always
 * execution to be executed several times as well as preventing infinite-
 * loops on recursive package installation.
 */
var packagesProcessed = new Array();

/** holds a list of packages which have been removed during this execution
 * This is used to prevent removing packages multiple times during a session
 * because they are referenced as dependencies by multiple other packages.
 */
var packagesRemoved = new Array();

/** hostname used within script */
var hostname = null;

/** FS object where the settings are stored */
var settings_file = null;

/** declare variables for data storage */
var packages = null;
var profiles = null;
var hosts = null;
var settings = null;
var config = null;

/** profiles applying to the current host */
var applyingProfiles = null;

/** caches the host node entry in order not to be re-evaluated each time */
var applyingHostNode = null;

/** stores the locale ID (LCID) which applies for the local machine */
var LCID = null;

/** caches the language node applying to the current system locale */
var languageNode = null;

/** declare log level variable */
var logLevel = null;

/** actual value for log level */
var logLevelValue = 0x03;

/** declare quet mode variable */
var quiet = null;

/** holds name of profiles applying to current host  */
var profilesApplying = null;

/** current value of quiet operation flag */
var quietMode = false;

/** stores if a postponed reboot is scheduled */
var postponedReboot = false;

/** set to true when a reboot is in progress */
var rebooting = false;

/** set to true to skip write attempts to event log */
var skipEventLog = false;

/** holds an array of packages which were not removed due to the /noremove flag */
var skippedRemoveNodes = null;

/**
 * Marks volatile releases and "inverts" the algorithm that a longer
 * version number is newer. For example 1.0RC2 would be newer than 1.0 because
 * it appends characters to the version. Using "rc" as a volatile release
 * marker the algorithm ignores the appendix and assumes that the string which
 * omits the marker is newer.
 * Resulting in 1.0 to be treated as newer than 1.0RC2.
 * NOTE: The strings are compared as lower-case. So use lower-case
 * definitions only!
 */
var volatileReleaseMarkers = ["rc", "i", "m", "alpha", "beta", "pre", "prerelease"];

/** stores if system is running on a 64-bit OS */
var x64 = null;

/*******************************************************************************
 *
 * Program execution
 *
 ******************************************************************************/

/**
 * Call the main function with arguments while catching all errors and
 * forwarding them to the error output.
 */
try {
	main();
} catch (e) {
	error("Message:      " + e.message + "\n" +
			"Description:  " + e.description + "\n" +
			"Error number: " + hex(e.number) + "\n" +
			"Stack:        " + e.stack  + "\n" +
			"Line:         " + e.lineNumber + "\n"
			);
	notifyUserFail();
	exit(2);
}

/**
 * Main execution method. Actually runs the script
 */
function main() {
	// do not open pop-up windows while initializing
	setQuiet(true);

	// initialize configuration (read and set values)
	initializeConfig();

	// parse command-line parameters
	parseArguments(getArgv());

	// print version number
	dinfo("WPKG " + WPKG_VERSION + " starting...");

	if (!isNoRunningState()) {
		setRunningState("true");
	}
	initialize();

	// Save a snapshot of the current environment
	saveEnv();
	
	// Process command line arguments to determine course of action.
	// Get special purpose argument lists.
	var argv = getArgv();
	var argn = argv.Named;
	var argu = argv.Unnamed;
	if (argn("query") != null) {
		var arg = argn("query").slice(0,1);
		if (arg == "a") {
			queryAllPackages();
		} else if (arg == "i") {
			queryInstalledPackages();
		} else if (arg == "x") {
			queryUninstalledPackages();
		} else if (arg == "u") {
			queryUpgradablePackages();
		}
	} else if (argn("show") != null) {
		var requestedPackageName = argn("show");
		// if case sensitive mode is disabled convert package name to lower case
		if (!isCaseSensitive()) {
			requestedPackageName = requestedPackageName.toLowerCase();
		}
		var message = queryPackage(getPackageNodeFromAnywhere(requestedPackageName));
		info(message);
	} else if (argn("install") != null) {
		installPackageName(argn("install"));
	} else if (argn("remove") != null) {
		removePackageName(argn("remove"));
	} else if (argn("upgrade") != null) {
		installPackageName(argn("upgrade"));
	} else if (isArgSet(argv, "/synchronize")) {
		synchronizeProfile();
	} else {
		showUsage();
		throw new Error("No action specified.");
	}
	exit(0);
}


/**
 * Adds a sub-node for the given XML node antry.
 *
 * @param XMLNode the XML node to add to (e.g. packges or settings)
 * @param subNode the node to be added to the XMLNode (for example a package node)
 *                NOTE: The node will be cloned before add
 * @return Returns true in case of success, returns false if no node could be added
 */
function addNode(XMLNode, subNode) {
	var returnvalue = false;
	var result = XMLNode.appendChild(subNode.cloneNode(true));
	if(result != null) {
		returnvalue = true;
	}
	return returnvalue;
}


/**
 * Adds a package node to the setings XML node. In case a package with the same
 * ID already exists it will be replaced.
 *
 * @param packageNode the package XML node to add.
 * @return true in case of success, otherwise returns false
 */
function addSettingsNode(packageNode) {
	// first remove entry if one already exists

	// get current settings node
	var packageID = getPackageID(packageNode);
	var settingsNode = getSettingNode(packageID);

	if (settingsNode != null) {
		dinfo("Removing currently existing settings node first: '" +
				getPackageName(settingsNode) + "' (" + getPackageID(settingsNode) +
				"), Revision " + getPackageRevision(settingsNode));
		removeSetingsNode(settingsNode);
	}

	dinfo("Adding settings node: '" +
			 getPackageName(packageNode) + "' (" + getPackageID(packageNode) +
			 "), Revision " + getPackageRevision(packageNode));

	return addNode(getSettings(), packageNode);
}

/**
 * Adds a package node to the list of skipped packages during removal process.
 *
 * @param packageNode the node which has been skipped during removal
 */
function addSkippedRemoveNodes(packageNode) {
	var skippedNodes = getSkippedRemoveNodes();
	skippedNodes.push(packageNode);
}

/**
 * Appends dependent profile nodes of the specified profile to the specifed
 * array. Recurses into self to get an entire dependency tree.
 */
function appendProfileDependencies(profileArray, profileNode) {
	var profileNodes = getProfileDependencies(profileNode);

	// add nodes if they are not yet part of the array
	for (var i=0; i < profileNodes.length; i++) {
		var currentNode = profileNodes[i];
		if(!searchArray(profileArray, currentNode)) {
			dinfo("Adding profile dependencies of profile '" +
					getProfileID(profileNode) + "': '" +
					getProfileID(currentNode) + "'");
			profileArray.push(currentNode);

			// add dependencies of these profiles as well
			appendProfileDependencies(profileArray, currentNode);
		} else {
			dinfo("Profile '" +
					getProfileID(currentNode) + "' " +
					"already exists in profile dependency tree. Skipping.");
		}
	}
}

/**
 * Checks for the success of a check condition for a package.
 *
 * @param checkNode XML check node to be evaluated
 * @throws Error Thows error in case of invalid XML node definition
 */
function checkCondition(checkNode) {
	var checkType = checkNode.getAttribute("type");
	var checkCond = checkNode.getAttribute("condition");
	var checkPath = checkNode.getAttribute("path");
	var checkValue = checkNode.getAttribute("value");

	// Sanity check: must have Type set here.
	if (checkType == null) {
		throw new Error("Check Type is null - this is not permitted. Perhaps a typo? " +
						"To help find it, here are the other pieces of information: " +
						"condition='"+checkCond+"', path='"+checkPath+"', value='"+checkValue+"'");
	}

	switch(checkType) {
	// check type: registry
	case "registry":
		// Sanity check: must have Cond and Path set for all registry checks.
		if ((checkCond == null) || (checkPath == null)) {
			throw new Error("Condition and / or path is null for a registry check. Perhaps " +
							"a typo? To help find it, here are the other pieces of information: " +
							"condition='"+checkCond+"', path='"+checkPath+"', value='"+checkValue+"'");
		}

		// branch on check condition
		switch (checkCond) {
		case "exists":
			if (getRegistryValue(checkPath) != null) {
				// Some debugging information.
				dinfo("The registry path '" + checkPath + "' exists: the check was successful");
				return true;
			} else {
				// Some debugging information.
				dinfo("The registry path '" + checkPath + "' does not exist: the check failed");
				return false;
			}
		case "equals":
			// read registry value and convert it to string in order to compare to supplied
			// string within the 'value' attribute
			var readValue = getRegistryValue(checkPath);

			// check if value is eventually null (non-existing)
			if (readValue == null) {
				dinfo("The registry path '" + checkPath + "' did not exist. Check failed.");
				return false;
			}

			// try treating the value as array
			var registyValue = "";
			try {
				var readArray = readValue.toArray();
				dinfo("The registry value received is an array, concatenating values for comparison.");
				for (var iRegKey=0; iRegKey<readArray.length; iRegKey++) {
					registyValue = registyValue + readArray[iRegKey] + "";
					if ( (iRegKey+1) < readArray.length) {
						registyValue += "\n";
					}
				}
			} catch(notAnArray) {
				dinfo("The registry value received is a scalar value");
				registyValue = readValue + "";
			}

			if (registyValue == checkValue) {
				// Some debugging information.
				dinfo("The registry path '" + checkPath + "' contained the correct value: '" +
						checkValue + "'. The check was successful");
				return true;
			} else {
				// try if expanded value matches (case-insensitive)
				var registryCompareShell = new ActiveXObject("WScript.Shell");
				expandedCheckValue = registryCompareShell.ExpandEnvironmentStrings(checkValue);
				if (registyValue.toLowerCase() == expandedCheckValue.toLowerCase()) {
					dinfo("The registry path '" + checkPath + "' contained the expanded value: '" +
						  expandedCheckValue + "'. The check was successful");
					  return true;
				} else {
					info("The registry path '" + checkPath + "' did not contain the value: '" +
							 checkValue + "'. Instead it contained '" + registyValue + "'. the check failed");
					return false;
				}
			}
		default:
			throw new Error("Check condition " + checkCond + " unknown " +
							"for type registry.");
		}

	// check type: file
	case "file":
		// Sanity check: must have Cond and Path set for all file checks.
		if ((checkCond == null) ||
			(checkPath == null)) {
			throw new Error("Condition and / or path is null for a file check. Perhaps " +
							"a typo? To help find it, here are the other pieces of information: " +
							"condition='"+checkCond+"', path='"+checkPath+"', value='"+checkValue+"'");
		}

		// expand environment variables
		// TODO: Use this type of shell everywhere?
		var fileCompareShell = WScript.CreateObject("WScript.Shell");
		checkPath = fileCompareShell.ExpandEnvironmentStrings(checkPath);
		
		if (checkCond == "exists") {
			var fso = new ActiveXObject("Scripting.FileSystemObject");
			if (fso.FileExists(checkPath)) {
				// Some debugging information.
				dinfo("The path '"+checkPath+"' exists: the test was successful");
				return true;
			} else {
				// Some debugging information.
				dinfo("The path '"+checkPath+"' does not exist: the test failed");
				return false;
			}

		} else if (checkCond == "sizeequals") {
			// sanity check: must have Value set for a size check.
			if (checkValue == null) {
				throw new Error("Value is null for a file sizeequals check. Perhaps " +
								"a typo? To help find it, here are the other pieces of information: " +
								"condition='" + checkCond +
								"', path='" + checkPath +
								"', value='" + checkValue + "'");
			}

			filesize=getFileSize(checkPath);
			if (filesize == checkValue) {
				dinfo("The file '"+checkPath+"' has size "+filesize+": the test was successful");
				return true;
			} else {
				dinfo("The file '"+checkPath+"' has size "+filesize+" - wanted "+
						checkValue+": the test fails");
			}
		} else if (checkCond.substring(0,7) == "version") {
			// Sanity check: Must have a value set for version check.
			if (checkValue == null) {
				throw new Error("Value is null for a file version check. Perhaps " +
								"a type? To help find it, here are the other pieces of information: " +
								"condition='" + checkCond + "', path='" + checkPath +
								"', value='" + checkValue + "'");
			} // if checkValue == null

			var fileVersion = getFileVersion(checkPath);

			var CheckValFromFileSystem = getFileVersion(checkPath);
			if (fileVersion == null || fileVersion == "") {
				 // no file version could be obtained
				 dinfo("Unable to find the file version for " + checkPath);
				 return false;
			}

			var fileVersionCompare = versionCompare(CheckValFromFileSystem, checkValue);
			dinfo ("Checking file version " + CheckValFromFileSystem + " is " + checkCond +
					 " (than) " + checkValue + " - got result " + fileVersionCompare);

			var fileVersionCompResult = false;
			switch (checkCond) {
				case "versionsmallerthan":
					if (fileVersionCompare < 0) {
						fileVersionCompResult = true;
					}
					break;
				case "versionlessorequal":
					if (fileVersionCompare <= 0) {
						fileVersionCompResult = true;
					}
					break;
				case "versionequalto":
					if (fileVersionCompare == 0) {
						fileVersionCompResult = true;
					}
					break;
				case "versiongreaterorequal":
					if (fileVersionCompare >= 0) {
						fileVersionCompResult = true;
					}
					break;
				case "versiongreaterthan":
					if (fileVersionCompare > 0) {
						fileVersionCompResult = true;
					}
					break;
				default:
					error("Unknown operation on file versions : " + checkCond);
					fileVersionCompResult = false;
					break;
			}

			dinfo("File version check for file '" + checkPath + "' returned " +
				fileVersionCompResult + " for operation type " + checkCond);
			return fileVersionCompResult;


		} else {
			throw new Error("Check condition " + checkCond + " unknown for " +
							"type file.");
		}
		break;

	// check type: uninstall
	case "uninstall":
		// Sanity check: must have Cond and Path set for all uninstall checks.
		if ((checkCond == null) ||
			(checkPath == null)) {
			throw new Error("Condition and / or path is null for an uninstall check. Perhaps " +
							"a typo? To help find it, here are the other pieces of information: " +
							"condition='" + checkCond +
							"', path='" + checkPath + "'");
		}
		var uninstallLocations = scanUninstallKeys(checkPath);

		if (checkCond == "exists") {
			if (uninstallLocations.length > 0) {
				dinfo("Uninstall entry for " + checkPath + " was found: test successful");
				return true;
			} else {
				dinfo("Uninstall entry for " + checkPath + " missing: test failed");
				return false;
			}
		} else if (checkCond.substring(0,7) == "version") {
			// check versions of all installed instances
			// for version checks we need a value
			if (checkValue == null) {
				throw new Error ("Uninstall entry version check has been specified but no" +
						"'value' is defined. Please add a 'value=<version>' sttribute.");
			}

			for (var iUninstKey=0; iUninstKey < uninstallLocations.length; iUninstKey++) {
				var uninstallValue = getRegistryValue(uninstallLocations[iUninstKey] + "\\DisplayVersion");

				dinfo("Found version of '" + checkPath + "' at " + uninstallLocations[iUninstKey] +
					": " + uninstallValue + "\n" + "Comparing to expected version: " + checkValue);

				// check if valid version value was returned
				if (uninstallValue == null || uninstallValue == "") {
					error("Check condition '" + checkCond + "' cannot be executed" +
						" since no version information is available for '" + checkPath + "'" +
						" at " + uninstallLocations[iUninstKey]);
					return false;
				}

				var uninstallVersionCompare = versionCompare(uninstallValue, checkValue);
				dinfo ("Comparing uninstall version '" + uninstallValue + "' to expected version '" +
					checkValue + "' using condition '" + checkCond  + "' returned " + uninstallVersionCompare);

				var uninstallVersionCompResult = false;
				switch (checkCond) {
					case "versionsmallerthan":
						if (uninstallValue < 0) {
							uninstallVersionCompResult = true;
						}
						break;
					case "versionlessorequal":
						if (uninstallVersionCompare <= 0) {
							uninstallVersionCompResult = true;
						}
						break;
					 case "versionequalto":
						if (uninstallVersionCompare == 0) {
							uninstallVersionCompResult = true;
						}
						break;
					case "versiongreaterorequal":
						if (uninstallVersionCompare >= 0) {
							uninstallVersionCompResult = true;
						}
						break;
					 case "versiongreaterthan":
						if (uninstallVersionCompare > 0) {
							uninstallVersionCompResult = true;
						}
						break;
					default:
						error("Unknown operation on uninstall version check: " + checkCond);
						uninstallVersionCompResult = false;
						break;
				}

				dinfo("Uninstall version check for package '" + checkPath + "' returned " +
					uninstallVersionCompResult + " for operation type " + checkCond);

				// in case the current entry does not match the condition, immediately return
				// else the next uninstall entry might be checked
				if (uninstallVersionCompResult == false) {
					return uninstallVersionCompResult;
				}
			}

			// it looks like all entries evaluated true
			return true;
		} else {
			throw new Error("Check condition " + checkCond + " unknown for " +
							"type uninstall.");
		}

	// check type: execution
	case "execute":
		// check if path to script is given
		if (checkPath == null) {
			throw new Error("No path is specified for execute check!");
		}
		if (checkValue == null || checkValue == "") {
			checkValue = 0;
		} else {
			checkValue = parseInt(checkValue);
		}

		// execute scit and catch return code
		var shell = new ActiveXObject("WScript.Shell");
		checkPath=shell.ExpandEnvironmentStrings(checkPath);
		var exitCode = exec(checkPath, 3600, null);

		var executeResult = false;
		switch (checkCond) {
			case "exitcodesmallerthan":
				if (exitCode < checkValue) {
					executeResult = true;
				}
				break;
			case "exitcodelessorequal":
				if (exitCode <= checkValue) {
					executeResult = true;
				}
				break;
			 case "exitcodeequalto":
				if (exitCode == checkValue) {
					executeResult = true;
				}
				break;
			case "exitcodegreaterorequal":
				if (exitCode >= checkValue) {
					executeResult = true;
				}
				break;
			 case "exitcodegreaterthan":
				if (exitCode > checkValue) {
					executeResult = true;
				}
				break;
			default:
				dinfo("No execute condition specified, assuming exit code of 0 to be" +
					" successful, everything else to be unsuccessful");
				if (exitCode == 0) {
					executeResult = true;
				} else {
					executeResult = false;
				}
				break;
		}

		dinfo("Execute check for program '" + checkPath + "' returned '" +
				exitCode + "'. Evaluating condition '" + checkCond +
				"' revealed " + executeResult + " when comparing to expected" +
				" value of '" + checkValue + "'");
		return executeResult;

	// check type: logical
	case "logical":

		// check if logical condition is set
		if (checkCond == null) {
			throw new Error("Condition is null for a logical check.");
		}

		var subcheckNodes = checkNode.selectNodes("check");

		switch (checkCond) {
		case "not":
			if (subcheckNodes.length == 1) {
				retval = !checkCondition(subcheckNodes[0]);
				dinfo("Result of logical 'NOT' check therefore " + retval);
				return retval;
			} else {
				throw new Error("Check condition 'not' requires one and only " +
						 "one child check condition. Instead " + checkNodes.length + " childs have been found");
			}
		case "and":
			for (var iAndNodes = 0; iAndNodes < subcheckNodes.length; iAndNodes++) {
				// check if one of the subchecks return false
				if (!checkCondition(subcheckNodes[iAndNodes])) {
					dinfo("Result of logical 'AND' check is false");
					return false;
				}
			}
			dinfo("Result of logical 'AND' check is true");
			return true;
		case "or":
			// check if one of the sub-checks returns true
			for (var iOrNodes = 0; iOrNodes < subcheckNodes.length; iOrNodes++) {
				if (checkCondition(subcheckNodes[iOrNodes])) {
					dinfo("Result of logical 'OR' check is true");
					return true;
				}
			}
			dinfo("Result of logical 'OR' check is false");
			return false;
		case "atleast":
			if (checkValue == null) {
				throw new Error("Check condition logical 'atleast' requires a value ");
			}

			// count number of checks which return true
			var numAtLeastNodes=0;
			for (var iAtLeastNodes = 0; iAtLeastNodes < subcheckNodes.length; iAtLeastNodes++) {
				if (checkCondition(subcheckNodes[iAtLeastNodes])) {
					numAtLeastNodes++;
				}
				// check if at least x checks revealed true
				if (numAtLeastNodes >= checkValue) {
					dinfo("Result of logical 'AT LEAST' check is true");
					return true;
				}
			}
			dinfo("Result of logical 'AT LEAST' check is false");
			return false;
		case "atmost":
			// check if maximum x checks return true
			var numAtMostNodes = 0;
			for (var iAtMostNodes = 0; iAtMostNodes < subcheckNodes.length; iAtMostNodes++) {
				if (checkCondition(subcheckNodes[iAtMostNodes])) {
					numAtMostNodes++;
				}
				if (numAtMostNodes > checkValue) {
					dinfo("Result of logical 'AT MOST' check is false");
					return false;
				}
			}
			// Result will be true now.
			dinfo("Result of logical 'AT MOST' check is true");
			return true;
		default:
			throw new Error("Check condition " + checkCond + " unknown for " +
			"type logical.");
		}

	// no such check type
	default:
		throw new Error("Check condition type " + checkType + " unknown.");
	}

	return false;
}

/**
 * Creates a new hosts XML root-node and returns it
 *
 * @return new hosts node
 */
function createHosts() {
	var newHosts = createXml("wpkg");
	return newHosts;
}

/**
 * Creates a new packages XML root-node and returns it
 *
 * @return new profiles node
 */
function createPackages() {
	var newPackages = createXml("packages");
	return newPackages;
}

/**
 * Creates a new profiles XML root-node and returns it
 *
 * @return new profiles node
 */
function createProfiles() {
	var newProfiles = createXml("profiles");
	return newProfiles;
}

/**
 * Creates a new settings XML root-node and returns it
 *
 * @return new settings node
 */
function createSettings() {
	var newSettings = createXml("wpkg");
	return newSettings;
}

/**
 * Create a new settings XML root-node by reading a file and returns it
 *
 * @return settings root node as stored within the file
 */
function createSettingsFromFile(fileName) {
	var newSettings = loadXml(settings_file, null, null);
	return newSettings;
}

/**
 * Downloads a file as specified within a download node.
 *
 * @param downloadNode XML 'download' node to be used
 * @return true in case of successful download, false in case of error
 */
function download(downloadNode) {
	// get attributes
	var url = getDownloadUrl(downloadNode);
	var target = getDownloadTarget(downloadNode);
	var timeout = getDownloadTimeout(downloadNode);

	// initiate download
	return downloadFile(url, target, timeout);
}

/**
 * Downloads all files from the given array of download XML nodes
 *
 * @param downloadNodes Array of download XML nodes to be downloaded
 * @return true in case of successful download, false in case of error
 */
function downloadAll(downloadNodes) {
	var returnValue = true;
	if (downloadNodes != null) {
		for (var i=0; i<downloadNodes.length; i++) {
			var result = download(downloadNodes[i]);
			// stop downloading if
			if (result != true) {
				returnValue = false;
			}
		}
	}
	return returnValue;
}

/**
 * Removes eventually existing temporary downloads of the specified XML node
 *
 * @param downloadNode XML node which contains the download definition to clean
 */
function downloadClean(downloadNode) {
	// get download attributes
	var target = getDownloadTarget(downloadNode);

	// evaluate target directory
	if (target == null || target == "") {
			error("Invaid download target specified: " + target);
		target = downloadDir;
	} else {
		target = downloadDir + "\\" + target;
	}
	target = new ActiveXObject("WScript.Shell").ExpandEnvironmentStrings(target);
	var fso = new ActiveXObject("Scripting.FileSystemObject");
	// delete temporary file if it already exists
	if (fso.fileExists(target)) {
		fso.deleteFile(target);
	}
}


/**
 * Cleans all temporary files belonging to the download XML nodes within
 * the passed array of download XML nodes
 *
 * @param downloadNodes Array of download XML nodes
 */
function downloadsClean(downloadNodes) {
	if (downloadNodes != null) {
		for (var i=0; i<downloadNodes.length; i++) {
			downloadClean(downloadNodes[i]);
		}
	}
}


/**
 * Builds settings document tree containing actually installed packages.
 * Tests all packages from given doc tree for "check" conditions.
 * If given conitions are positive, package is considered as installed.
 */
function fillSettingsWithInstalled() {

	var packagesNodes = getPackageNodes();

	// check each available package
	for (var i = 0; i < packagesNodes.length; i++) {
		var packNode = packagesNodes[i];

		// add package node to settings if it is installed
		if (isInstalled(packNode)) {
			addSettingsNode(packNode);
		}
	}
}

/**
 * Returns the command line argument for this command node. A command node can
 * be an <install/>, <upgrade/> or <remove/> node.
 *
 * @param cmdNode cmd XML node to read from
 * @return command defined within the given cmd XML node, returns empty string
 *         if no command is defined.
 */
function getCommandCmd(cmdNode) {
	var cmd = cmdNode.getAttribute("cmd");
	if (cmd == null) {
		cmd = "";
	}
	return cmd;
}

/**
 * Returns the value of an exit code node within the given command node.
 * A command node can be an <install/>, <upgrade/> or <remove/> node.
 * In case no such exit code was defined null will be returned.
 * In case the code is defined the string "success" is returned.
 * In case the exit code specifies an immediate reboot then the string
 * "reboot" is returned.
 *
 * @return returns string "reboot" in case a reboot is required.
 *         returns string "delayedReboot" in case a reboot should be scheduled as soon as possible
 *         returns string "postponedReboot" in case a reboot after installing all packages is required
 *         returns string "success" in case exit code specifies sccessful installation.
 *         returns null in case the exit code is not defined.
 */
function getCommandExitCodeAction(cmdNode, exitCode) {
	var returnValue = null;
	var exitNode = cmdNode.selectSingleNode("exit[@code='" + exitCode + "']");
	if (exitNode == null) {
		exitNode = cmdNode.selectSingleNode("exit[@code='any']");
	}
	if (exitNode != null) {
		if (exitNode.getAttribute("reboot") == "true") {
			// This exit code forces a reboot.
			info("Command '" + getCommandCmd(cmdNode) + "' returned " +
				" exit code [" + exitCode + "]. This exit code " +
				"requires an immediate reboot.");
			returnValue = "reboot";
		} else if (exitNode.getAttribute("reboot") == "delayed")  {
			info("Command '" + getCommandCmd(cmdNode) + "' returned " +
				" exit code [" + exitCode + "]. This exit code " +
				"shedules a reboot after execution of all commands.");
			returnValue = "delayedReboot";
		} else if (exitNode.getAttribute("reboot") == "postponed")  {
			info("Command '" + getCommandCmd(cmdNode) + "' returned " +
				" exit code [" + exitCode + "]. This exit code " +
				"shedules a reboot after execution of all packages.");
			returnValue = "postponedReboot";
		} else {
			// This exit code is successful.
			info("Command '" + getCommandCmd(cmdNode) + "' returned " +
				" exit code [" + exitCode + "]. This exit code " +
				"is not an error.");
			returnValue = "success";
		}
	}
	return returnValue;
}

/**
 * Returns the timeout value for this command node. A command node can
 * be an <install/>, <upgrade/> or <remove/> node.
 *
 * @param cmdNode cmd XML node to read from.
 * @return the timeout for the given cmd XML node - returns 0 if no timeout is defined
 */
function getCommandTimeout(cmdNode) {
	var timeout = cmdNode.getAttribute("timeout");
	if (timeout == null) {
		timeout = 0;
	}
	return parseInt(timeout);
}

/**
 * Returns the value of the workdir attribute of the given cmd XML node.
 *
 * @param cmdNode cmd XML node to read from
 * @return the workdir attribute value. Returns null in case value is not defined.
 */
function getCommandWorkdir(cmdNode) {
	var workdir = cmdNode.getAttribute("workdir");
	return workdir;
}

/**
 * Returns XML node which contains the configuration
 */
function getConfig() {
	if (config == null) {
		// load config

		// get argument list
		var argv = getArgv();
		// Get special purpose argument lists.
		var argn = argv.Named;

		// if set to true it will throw an error to quit in case of file-not-found
		var exitIfNotFound = false;

		// stores config file path
		var config_file = null;

		// will be used for file operations
		var fso = new ActiveXObject("Scripting.FileSystemObject");

		if (argn("config") != null) {
			var configPath = argn("config");
			var wshObject = new ActiveXObject("WScript.Shell");
			var expConfigPath = wshObject.ExpandEnvironmentStrings(configPath);
			config_file = fso.GetAbsolutePathName(expConfigPath);
			// config was explicitely specified - I think we should quit if it
			// is not available
			exitIfNotFound = true;
		} else {
			// if config_file_name (config.xml) exists, use it
			var fullScriptPATH = WScript.ScriptFullName;
			var base = fso.GetParentFolderName(fullScriptPATH);
			config_file = fso.BuildPath(base, config_file_name);
			// config is optional in this case
			exitIfNotFound = false;
		}

		if (fso.fileExists(config_file)) {
			try {
				// Read in config.xml.
				config = loadXml(config_file, null);
				if (config == null) {
					throw new Error("Unable to parse config file!");
				}
			} catch (e) {
				// There was an error proccessing the config.xml file.  Alert the user
				error("Error reading "+ config_file + ": " + e.description);
				exit(99); // Exit code 99 means config.xml read error.
			}
		} else {
			var message = config_file + " could not be found.";
			if (exitIfNotFound) {
				error(message);
				exit(99); // Exit code 99 means config.xml read error.
			} else {
				dinfo(message);
			}
		}
		// create empty config if no config could be read
		if (config == null) {
			config = createXml("config");
		}
	}
	return config;
}

/**
 * Returns array of <param> nodes from the configuration.
 * Returns array of size 0 in case no parameter is defined.
 *
 * @return <param> nodes
 */
function getConfigParamArray() {
	return getConfig().selectNodes("param");
}

/**
 * Returns 'download XML node array on a given XML node
 * @param xmlNode the xml node to read child-nodes of type download from
 * @param downloadsArray array of downloads to be extended with the ones from
 *             the given XML node, specify null to return a new array.
 * @return XML node array on a given package XML node containing all package
 *         downloads.
 *         returns emtpy array if no downloads are defined
 */
function getDownloads(xmlNode, downloadsArray) {
	if (downloadsArray == null) {
		downloadsArray = new Array();
	}
	var downloads = xmlNode.selectNodes("download");
	if (downloads != null && downloads.length > 0) {
		for(var i=0; i<downloads.length; i++) {
			downloadsArray.push(downloads[i]);
		}
	}
	return downloadsArray;
}

/**
 * Returns 'target' attribute from the given download XML node
 *
 * @param downloadNode download XML node
 * @return value of 'target' attribute, null if attribute is not defined
 */
function getDownloadTarget(downloadNode){
	return downloadNode.getAttribute("target");
}

/**
 * Returns 'timeout' attribute from the given download XML node
 *
 * @param downloadNode download XML node
 * @return value of 'timeout' attribute, returns value of downloadTimeout
 *         if no timeout value exists or it cannot be parsed.
 *         Returns integer.
 */
function getDownloadTimeout(downloadNode) {
	var returnValue = downloadTimeout;
	var timeout = downloadNode.getAttribute("timeout");
	if (timeout != null) {
		try {
			returnValue = parseInt(timeout);
		} catch(e) {
			error("Erorr parsing timeout attribute: " + e.description);
		}
	}

	return returnValue;
}

/**
 * Returns 'url' attribute from the given download XML node
 *
 * @param downloadNode download XML node
 * @return value of 'url' attribute, null if attribute is not defined
 */
function getDownloadUrl(downloadNode) {
	return downloadNode.getAttribute("url");
}

/**
 * Gets the size of a file (in Bytes). The path is allowed to contain
 * environment variables like "%TEMP%\somefile.txt".
 *
 * @param path to the file whose size has to be returned
 * @return size of the file (in Bytes), returns -1 if file size could not be determined
 */
function getFileSize (file) {
	var size = -1;
	try {
		dinfo ("Finding size of " + file + "\n");
		var expandedPath = new ActiveXObject("WScript.Shell").ExpandEnvironmentStrings(file);
		var FSO = new ActiveXObject("Scripting.FileSystemObject");
		var fsof = FSO.GetFile(expandedPath);
		size = fsof.Size;
	} catch (e) {
		size = -1;
		dinfo("Unable to get file size for " + file + " : " +
				 e.description);
	}
	dinfo ("Leaving getFileSize with size " + size);
	return size;
}

/**
 * Returns the version of a file.
 *
 * @return string representation of version, null in case no version could be read.
 */
function getFileVersion (file) {
	var version = null;
	try {
		dinfo ("Trying to find version of " + file);
		var FSO = new ActiveXObject("Scripting.FileSystemObject");
		version = FSO.GetFileVersion(file);
		dinfo ("Obtained version '" + version + "'.");
	} catch (e) {
		version = null;
		dinfo("Unable to find file version for " + file + " : " +
			e.description);
	}
	return version;
}

/**
 * Returns the hostname of the machine running this script. The hostname might
 * be overwritten by the /host:<hostname> switch.
 */
function getHostname() {
	if (hostname == null) {
		var WshNetwork = WScript.CreateObject("WScript.Network");
		setHostname(WshNetwork.ComputerName.toLowerCase());
	}
	return hostname;
}

/**
 * Returns a string representing the regular expresion associated to the host
 * definition in hosts.xml.
 */
function getHostNameAttribute(hostNode) {
	return hostNode.getAttribute("name");
}


/**
 * Retrieves profile from given "hosts" XML document.
 * Searches for node having attribute "name" matching
 * given hostName. Returns it's attribute "profile-id".
 *
 * Check is performed using regular expression object:
 * "name" attribute value as the pattern and
 * hostName as matched string.
 * First matching profile is returned.
 *
 * @param hostName Name of host to retrieve the profile node for. If null is
 *                 supplied the host node of the current host will be used.
 */
function getHostNode() {
	if (applyingHostNode == null) {
		var hostName = getHostname();
		if(hostName == null) {
			// Error! Lack of host name.
			throw new Error("Error! Lack of host name!");
		}
		// get available host definitions
		var hostNodes = getHostNodes();

		// try non-regular-expression matching
		for (var iHosts=0; iHosts < hostNodes.length; iHosts++) {
			var hostNodeDirectMatch = hostNodes[iHosts];

			if (hostNodeDirectMatch != null) {
				var hostNameAttribute = getHostNameAttribute(hostNodeDirectMatch);

				if (hostNameAttribute != null) {

					if (hostName.toUpperCase() == hostNameAttribute.toUpperCase()) {
						applyingHostNode = hostNodeDirectMatch;
						return hostNodeDirectMatch;
					}
				}
			}
		}

		// try IPv4-address matching
		try {
			// get IPv4 addresses (might be multiple)
			var ipAddresses = getIPAddresses();

			// check for each address if a host node matches
			// try non-regular-expression matching
			for (var iIPAdresses=0; iIPAdresses < ipAddresses.length; iIPAdresses++) {
				var ipAddress = ipAddresses[iIPAdresses];

				// check if any of the patterns within the hosts definition matches
				for (var iHostMatch=0; iHostMatch < hostNodes.length; iHostMatch++) {
					var hostNode = hostNodes[iHostMatch];

					if (hostNode != null) {
						var matchPattern = getHostNameAttribute(hostNode);

						if (matchPattern != null) {
							// splitvalues
							// dinfo("Trying to match IP '" + ipAddress + "' to " +
							// 	  "'" + matchPattern + "'");
							var splitIP = ipAddress.split(".");
							var splitPattern = matchPattern.split(".");
							// check if format was correct
							if (splitIP.length == 4 &&
								splitPattern.length == 4) {
								var firstValue = 0;
								var secondValue = 0;
								var match = true;
								for (var k=0; k<splitIP.length; k++) {
									// get first range value
									var ipOctet = parseInt(splitIP[k]);
									var matchOctet = splitPattern[k];

									// check if ip octet defines a range
									var splitMatchOctet = matchOctet.split("-");
									firstValue = parseInt(splitMatchOctet[0]);
									if (splitMatchOctet.length > 1) {
										secondValue = parseInt(splitMatchOctet[1]);
									} else {
										secondValue = firstValue;
									}
									if (firstValue > secondValue) {
										// swap values
										var temp = firstValue;
										firstValue = secondValue;
										secondValue = temp;
									}
									// let's finally see if the ip octet is outside the range
									if ((ipOctet < firstValue || ipOctet > secondValue)) {
										// if octet did not match the requirements
										// dinfo("no match!");
										match = false;
										// no need to continue
										break;
									}
								}
								// if all matched, take this profile
								if (match) {
									dinfo("Found profile '" + matchPattern +
											"' matching IP '" + ipAddress + "'");
									applyingHostNode = hostNode;
									return hostNode;
								}
							}
						}
					}
				}
			}
		} catch(e) {
			dinfo("IP-Address match failed: " + e.description);
		}

		// if direct match did not work, try regular expression match
		for (var i=0; i < hostNodes.length; i++) {
			hostNode = hostNodes[i];

			if (hostNode != null) {
				var hostNameAttrExpr = getHostNameAttribute(hostNode);

				if (hostNameAttrExpr != null) {
					var reg = new RegExp("^" + hostNameAttrExpr + "$", "i");

					if (reg.test(hostName)) {
						applyingHostNode = hostNode;
						return hostNode;
					}
				}
			}
		}

		throw new Error("Could not find profile for host " + hostName + ".");
	}
	return applyingHostNode;
}

/**
 * Returns an array of host nodes which specify the host regular expression
 * and the corresponding profile
 */
function getHostNodes() {
	return getHosts().selectNodes("host");
}

/**
 * Returns the profile-id associated with the given host node.
 * The node structure is defined as follows:
 * <host name='hostname' profile-id='main-profile'>
 * 	<profile id='profile1' />
 * 	<profile id='profile2' />
 * </host>
 * The profile-id or the enclosed <profile... /> nodes might be omitted but not
 * both!
 * @param hostNode XML node of the host definition
 * @return array of strings with referenced profiles
 * 		(array might be of length 0 if no profiles are defined)
 */
function getHostProfiles(hostNode) {
	// create array to store profile IDs
	var profileList = new Array();

	// try to receive profile ID from host node
	var profileID = hostNode.getAttribute("profile-id");

	if (profileID != null) {
		// convert to lower case if case-sensitivity is off
		if (!isCaseSensitive()) {
			profileList.push(profileID.toLowerCase());
		} else {
			profileList.push(profileID);
		}
	}

	var profileNodes = hostNode.selectNodes("profile");
	if (profileNodes != null) {
		for (var iProfile=0; iProfile<profileNodes.length; iProfile++) {
			var profileNode = profileNodes[iProfile];
			// get id attribute
			var profileId = profileNode.getAttribute("id");

			// convert to lower case if case-sensitivity is off
			if (!isCaseSensitive()) {
				profileList.push(profileId.toLowerCase());
			} else {
				profileList.push(profileId);
			}
		}
	}

	if (profileList.length > 0) {
		var message = "Profiles applying to the current host:\n";
		for (var iProfileIndex=0; iProfileIndex<profileList.length; iProfileIndex++) {
			message += profileList[iProfileIndex] + "\n";
		}
		dinfo(message);
	} else {
		error("No profiles assigned to the current host!");
	}

	return profileList;
}

/**
 * Returns XML node which contains all host configurations
 */
function getHosts() {
	if(hosts == null) {
		var newHosts = createHosts();
		setHosts(newHosts);
	}
	return hosts;
}

/**
 * Returns a list of variables from the applying host definition.
 *
 * @param dictionary Dictionary of type Scripting.Dictionary to which the the
 *        variables are written to (existing values are overwritten).
 *        In case null is supplied it returns a new dictionary object.
 * @return Object of type Scripting.Dictionary which contains all key/value
 *         pairs from the applying host.
 */
function getHostVariables(dictionary) {
	dinfo("Reading variables from host " + getHostNameAttribute(getHostNode()));
	// make sure variables is either assigned or created
	var variables;
	if (dictionary == null) {
		variables = new ActiveXObject("Scripting.Dictionary"); 
	} else {
		variables = dictionary;
	}

	// read variables from host XML node
	variables = getVariables(getHostNode(), variables);
	return variables;
}

/**
 * Returns the corresponding string defined within the configuration.
 *
 * @param stringID the identification of the corresponding string as
 *                 listed within the configuration
 *
 * @return returns the string as it appears within the configuration.
 *         Returns null if the string id is not defined.
 */
function getLocalizedString(stringID) {
	if (languageNode == null && getConfig() != null) {
		// read node which contains all the strings
		var languagesNodes = getConfig().selectNodes("languages");

		if (languagesNodes != null) {
			// there might be multiple languages nodes
			for (var i=0; i < languagesNodes.length; i++) {
				// get language nodes
				var languageNodes = languagesNodes[i].selectNodes("language");

				for (var j=0; j < languageNodes.length && languageNode == null; j++) {
					var currentLangNode = languageNodes[j];

					// get associated language LCIDs
					var lcidString = currentLangNode.getAttribute("lcid");
					var lcids = lcidString.split(",");
					for (var k=0; k < lcids.length; k++) {
						// check if it corresponds to the system LCID
						var currentLcid = trimLeadingZeroes(trim(lcids[k]));
						if (currentLcid == getLocale()) {
							dinfo("Found language definition node for language ID " + currentLcid);
							languageNode = currentLangNode;
							break;
						}
					}
				}
			}
		}

	}

	// check if language has not been found
	if (languageNode == null) {
		// create empty node
		languageNode = createXml("language");
	}

	// try to find node matching the requested sting id
	var stringNode = languageNode.selectSingleNode("string[@id='" + stringID + "']");
	if (stringNode != null) {
		return stringNode.text;
	} else {
		dinfo("No locale language definition found for message ID '" + stringID +
			"' (language LCID '" + getLocale() + "').");
		return null;
	}
}

/**
 * Returns array of package IDs which includes package IDs of chained
 * packages.
 * Returns emtpy array in case the package does not have any chained packages.
 *
 * @param packageNode the package node to read the list of chained packages
 *                    from
 * @param packageList optional reference to an array which is used to insert
 *                    the chaned packages to. Specify null to create a new
 *                    Array
 * @return Array specified in packageList parameter extended by package IDs
 *         (string values) which represent the chained packages
 */
function getPackageChained(packageNode, packageList) {
	// output array
	if (packageList == null) {
		packageList = new Array();
	}

	if(packageNode != null) {
		var includeNodes = packageNode.selectNodes("chain");
		if (includeNodes != null) {
			for (var i=0; i < includeNodes.length; i++) {
				var dependId = includeNodes[i].getAttribute("package-id");

				// convert to lower case if case-insensitive mode is on
				if (dependId != null) {
					if (!isCaseSensitive()) {
						dependId = dependId.toLowerCase();
					}
					packageList.push(dependId);
				}
			}
		}
	}

	return packageList;
}

/**
 * Returns 'check' XML node array on a given package XML node
 * @return XML node array on a given package XML node containing all package
 *         checks.
 *         returns emtpy array if no checks are defined
 */
function getPackageChecks(packageNode) {
	return packageNode.selectNodes("check");
}

/**
 * Returns 'downgrade' XML node array on a given package XML node
 *
 * @param packageNode package XML node which contains 'downgrade' nodes
 * @return Array of 'downgrade' XML nodes, returns empty array if no nodes are defined
 */
function getPackageCmdDowngrade(packageNode) {
	var nodes = packageNode.selectNodes("downgrade");
	if (nodes == null) {
		nodes = new Array();
	}
	return nodes;
}

/**
 * Returns 'install' XML node array on a given package XML node
 *
 * @param packageNode package XML node which contains 'install' nodes
 * @return Array of 'install' XML nodes, returns empty array if no nodes are defined
 */
function getPackageCmdInstall(packageNode) {
	var nodes = packageNode.selectNodes("install");
	if (nodes == null) {
		nodes = new Array();
	}
	return nodes;
}

/**
 * Returns 'remove' XML node array on a given package XML node
 *
 * @param packageNode package XML node which contains 'remove' nodes
 * @return Array of 'remove' XML nodes, returns empty array if no nodes are defined
 */
function getPackageCmdRemove(packageNode) {
	var nodes = packageNode.selectNodes("remove");
	if (nodes == null) {
		nodes = new Array();
	}
	return nodes;
}

/**
 * Returns 'install' XML node array on a given package XML node
 *
 * @param packageNode package XML node which contains 'remove' nodes
 * @return Array of 'remove' XML nodes, returns empty array if no nodes are defined
 */
function getPackageCmdUpgrade(packageNode) {
	var nodes = packageNode.selectNodes("upgrade");
	if (nodes == null) {
		nodes = new Array();
	}
	return nodes;
}

/**
 * Returns array of package IDs which represent the package dependencies.
 * Returns emtpy array in case the package does not have any dependency.
 *
 * @param packageNode the package node to read the list of dependencies from
 * @param packageList optional reference to an array which is used to insert
 *                    the dependencies to. Specify null to create a new Array
 * @return Array specified in packageList parameter extended by package IDs
 *         (string values) which represent the dependencies
 */
function getPackageDependencies(packageNode, packageList) {
	// output array
	if (packageList == null) {
		packageList = new Array();
	}

	if(packageNode != null) {
		var dependNodes = packageNode.selectNodes("depends");
		if (dependNodes != null) {
			for (var i=0; i < dependNodes.length; i++) {
				var dependId = dependNodes[i].getAttribute("package-id");

				// convert to lower case if case-insensitive mode is on
				if (dependId != null) {
					if (!isCaseSensitive()) {
						dependId = dependId.toLowerCase();
					}
					packageList.push(dependId);
				}
			}
		}
	}

	return packageList;
}

/**
 * Returns the package execute attribute value (String)
 *
 * @param packageNode the package node to get the attribute from
 * @return package execute attribute value, empty string if undefined
 */
function getPackageExecute(packageNode) {
	var execAttr = packageNode.getAttribute("execute");
	if (execAttr == null) {
		execAttr = "";
	}
	return execAttr;
}

/**
 * Returns the package ID string from the given package XML node.
 *
 * @return package ID
 */
function getPackageID(packageNode) {
	return packageNode.getAttribute("id");
}

/**
 * Returns array of package IDs which represent the package includes.
 * Returns emtpy array in case the package does not have any dependency.
 *
 * @param packageNode the package node to read the list of includes from
 * @param packageList optional reference to an array which is used to insert
 *                    the includes to. Specify null to create a new Array
 * @return Array specified in packageList parameter extended by package IDs
 *         (string values) which represent the includes
 */
function getPackageIncludes(packageNode, packageList) {
	// output array
	if (packageList == null) {
		packageList = new Array();
	}

	if(packageNode != null) {
		var includeNodes = packageNode.selectNodes("include");
		if (includeNodes != null) {
			for (var i=0; i < includeNodes.length; i++) {
				var dependId = includeNodes[i].getAttribute("package-id");

				// convert to lower case if case-insensitive mode is on
				if (dependId != null) {
					if (!isCaseSensitive()) {
						dependId = dependId.toLowerCase();
					}
					packageList.push(dependId);
				}
			}
		}
	}

	return packageList;
}

/**
 * Returns Date representation of 'installdate' attribute from the given
 * package.
 * 
 * @param packageNode the package node to read the 'installdate' attribute from
 * @return Date object representing installation date of the given package.
 *         Returns null in case the 'installdate' attribute is not set.
 */
function getPackageInstallDate(packageNode) {
	var installDate = null;
	var packageInstallDate = packageNode.getAttribute("installdate");
	if (packageInstallDate != null) {
		installDate = parseISODate(packageInstallDate, false);
	}
	return installDate;
}

/**
 * Returns the package name from the given package XML node
 *
 * @return returns the package name attribute - empty string if no name is defined
 */
function getPackageName(packageNode) {
	var packageName = "";
	if(packageNode != null) {
		packageName = packageNode.getAttribute("name");
		if (packageName == null) {
			packageName = "";
		}
	}
	return packageName;
}

/**
 * Returns the corresponding package XML node from the package database
 * (packages.xml). Returns null in case no such package exists.
 */
function getPackageNode(packageID) {
	// get first node which mached the specified ID
	return getPackages().selectSingleNode("package[@id='" + packageID +"']");
}

/**
 * Retruns the corresponding package XML node to the requested package ID by
 * searching the packages database first. If the package cannot be located
 * within the package database it prints an error and looks for the node within
 * the local settings database.
 * If even the local database does not contain such a package entry then it
 * prints an error about missing package definition. In case '/quitonerror' is
 * set it exits.
 * If the package could be located within the local package database it prints
 * a warning and returns the local package node.
 *
 * Algorithmic description:
 * search package node within local package database
 * if found
 * 		return it
 * else
 * 		print warning
 * 		loock for package within local settings
 * 		if found
 * 			print warning
 * 			return it
 * 		else
 * 			print error (or exit by throwing error in case of /quitonerror)
 * 			return null
 * 		fi
 * fi
 */
function getPackageNodeFromAnywhere(packageID) {
	var packageNode = null;

	// try to get package node from package database
	var packageDBNode = getPackageNode(packageID);

	// check if node exists; if not then try to get the node from the settings
	if(packageDBNode != null) {
		// package found in package database, mark for installation/upgrade
		dinfo("Found package node '" + getPackageName(packageDBNode) + "' (" +
				getPackageID(packageDBNode) + ") in package database");
		packageNode = packageDBNode;
	} else {
		// error package not in package database
		// looking for package node within the local settings file
		/*
			var packageNotFoundMessage =
					"Profile inconsistency: Package '" + packageID +
					"' does not exist within the package database. " +
					"Please contact your system administrator!";

			warning(packageNotFoundMessage);
		*/

		// try to get package node from local settings
		var packageSettingsNode = getSettingNode(packageID);

		// if no package definition has been found jet the package is not installed
		if(packageSettingsNode != null) {
			var messageLocalOnly = "Database inconsistency: Package with package ID '" +
							packageID + "' missing in package database. Package information " +
							"found on local installation:\n" +
							"Package ID: " + getPackageID(packageSettingsNode) + "\n" +
							"Package Name: " + getPackageName(packageSettingsNode) + "\n" +
							"Package Revision: " + getPackageRevision(packageSettingsNode) + "\n";
			warning(messageLocalOnly);
			packageNode = packageSettingsNode;
		} else {
			var messageNotFound = "Database inconsistency: Package with ID '" + packageID +
					"' does not exist within the package database or the local settings file. " +
					"Please contact your system administrator!";
			if (isQuitOnError()) {
				throw new Error(messageNotFound);
			} else {
				error(messageNotFound);
			}
		}
	}

	// return result
	return packageNode;
}

/**
 * Returns an array of all package nodes that can be installed. This list
 * includes all packages found in the package database. It does not include
 * local packages from the settings file (currently installed ones).
 * 
 * @return Array containing XML nodes (package nodes). Array might be of size 0
 */
function getPackageNodes() {
	// Retrieve packages.
	var packageNodes = getPackages().selectNodes("package");

	// make sure a package ID exists only once
	packageNodes = uniqueAttributeNodes(packageNodes, "id");

	// return this array
	return packageNodes;
}

/**
 * Returns the package notify attribute value
 *
 * @param packageNode the package node to get the notify attribute from
 * @return Notify attribute value (true in case of String "true" false otherwise.
 */
function getPackageNotify(packageNode) {
	var returnvalue = true;
	var notify = packageNode.getAttribute("notify");
	if (notify == "false") {
		returnvalue = false;
	}
	return returnvalue;
}

/**
 * Returns the package priority from the given package XML node
 *
 * @return package priority - returns 0 if no priority is defined
 */
function getPackagePriority(packageNode) {
	var priority = packageNode.getAttribute("priority");
	if (priority == null) {
		priority = 0;
	}
	return parseInt(priority);
}

/**
 * Returns the package reboot attribute value. This attribute can add
 * additional reboots but not limit or invalidate reboot flags set on the
 * command-level.
 * This value can have three states:
 * "true"      Immediate reboot after package installation.
 *             This will take precedence of any command-level reboot="postponed"
 *             attribute if present and reboot immediately after package
 *             installation.
 *             A reboot="true" attribute on command-level will still result in
 *             an immediate reboot.
 *             Resulting status depending on command-level reboot flag:
 *             "true"      immediate reboot after command execution
 *             "delayed"   reboot after package installation
 *             "postponed" reboot after package installation
 *             "false"     reboot after package installation
 * "postponed" Schedule reboot after installing all packages within this
 *             session, for example after synchronizing.
 *             Resulting status depending on command-level reboot flag:
 *             "true"      immediate reboot after command execution
 *             "delayed"   reboot after package installation
 *             "postponed" reboot after all actions are completed
 *             "false"     reboot after all actions are completed
 * "false"     No reboot unless one is defined at command-level.
 * or not set  Resulting status depending on command-level reboot flag:
 *             "true"      immediate reboot after command execution
 *             "delayed"   reboot after package installation
 *             "postponed" reboot after all actions are completed
 *             "false"     no reboot
 *
 * As a result there are four possibilities to schedule a reboot in order of
 * precedence:
 * immediate   Command node specified reboot=true, immediate reboot takes place.
 * package     Reboot is issued right after installing:
 *             - package specifies reboot="true"
 *               OR
 *             - any command node specified reboot="delayed"
 * postponed   Reboot will take place after all packages have been applied.
 *             - package specifies reboot="postponed"
 *               OR
 *             - any command node specified reboot="postponed"
 * none        No reboot is issued by this package:
 *             - package does not specify reboot or specifies reboot="false"
 *               AND
 *             - no command node specified any form of reboot reboot
 *
 * This means that an immediate reboot always has the highest priority. You
 * can just set "reboot markers" on a "timeline" on package and command level
 * where the closest reboot marker will be executed:
 * immediate => package => postponed => none
 *
 * @return one of the states (string values):
 *             "true", always reboot after package installation
 *             "postponed", reboot before script exits
 *             "false", reboot only if command specified reboot=delayed/postponed
 *
 */
function getPackageReboot(packageNode) {
	var rebootAction = "false";
	var packageReboot = packageNode.getAttribute("reboot");
	if (packageReboot != null) {
		if (packageReboot == "true") {
			rebootAction = packageReboot;
		} else if (packageReboot == "postponed") {
			rebootAction = packageReboot;
		}
	}
	return rebootAction;
}

/**
 * Adds all packages referenced by the specified package node to the given
 * array. In other words all dependencies, chained packages and includes
 * of the given node will be appended to the array. If you specify null or an
 * empty array the array returned will contain all packages from the dependency
 * tree of the given package node.
 * 
 * @param packageNode full dependency tree of the specified package will be
 *                    added to the given array.
 * @param packageArray Array to which all referenced packages are added to.
 *                     Specify null to create a new array finally containing
 *                     only the dependency tree of the specified package.
 * @return array containing all referenced packages (full package nodes).
 *         NOTE: The returned array is not sorted.
 */
function getPackageReferences(packageNode, packageArray) {
	if (packageArray == null) {
		packageArray = new Array();
	}

	// get dependencies, includes and chans
	var linkedPackageIDs = getPackageDependencies(packageNode, null);
	getPackageIncludes(packageNode, linkedPackageIDs);
	getPackageChained(packageNode, linkedPackageIDs);

	// add nodes if they are not yet part of the array
	for (var i=0; i < linkedPackageIDs.length; i++) {
		var currentNode = getPackageNodeFromAnywhere(linkedPackageIDs[i]);
		if (currentNode != null) {
			if(!searchArray(packageArray, currentNode)) {
				dinfo("Adding referenced package '" + getPackageName(currentNode) + "' (" +
						getPackageID(currentNode) + ") for package '" +
						getPackageName(packageNode) + "' (" + getPackageID(packageNode) +
						")");
				// add the package first (so it's not added again, this prevents loops)
				packageArray.push(currentNode);

				// add dependencies of these package as well
				getPackageReferences(currentNode, packageArray);
			} else {
				dinfo("Referenced package '"  + getPackageName(currentNode) + "' (" +
						getPackageID(currentNode) + ") for package '" +
						getPackageName(packageNode) + "' (" + getPackageID(packageNode) +
						") already added.");
			}
		}
	}
}

/**
 * Returns the package version string from the given package XML node.
 * Returns 0 if package has no revision specified.
 *
 * @return String representing the package revision (might be a dot-separated version)
 *         <#>[.<#>]*
 */
function getPackageRevision(packageNode) {
	var packageRevision = packageNode.getAttribute("revision");
	if (packageRevision == null) {
		packageRevision = 0 + "";
	}
	return packageRevision;
}

/**
 * Returns Date representation of 'uninstalldate' attribute from the given
 * package.
 * 
 * @param packageNode the package node to read the 'uinstalldate'
 *        attribute from
 * @return Date object representing uninstall date of the given package.
 *         Returns null in case the 'uninstalldate' attribute is not set.
 */
function getPackageUninstallDate(packageNode) {
	var uninstallDate = null;
	var packageUninstallDate = packageNode.getAttribute("uinstalldate");
	if (packageUninstallDate != null) {
		uninstallDate = parseISODate(packageUninstallDate, true);
	}
	return uninstallDate;
}

/**
 * Returns XML node which contains all packages (package database).
 */
function getPackages() {
	if(packages == null) {
		var newPackages = createPackages();
		setPackages(newPackages);
	}
	return packages;
}

/**
 * Returns a list of variables for the given package.
 *
 * @param packageNode The package node to get the variables from.
 * @param dictionary Dictionary of type Scripting.Dictionary to which the the
 *        variables are written to (existing values are overwritten).
 *        In case null is supplied it returns a new dictionary object.
 * @return Object of type Scripting.Dictionary which contains all key/value
 *         pairs from the given package including its dependencies
 */
function getPackageVariables(packageNode, dictionary) {
	dinfo("Reading variables from package " + getPackageName(packageNode));
	dictionary = getVariables(packageNode, dictionary);
	return dictionary;
}

/**
 * Returns array of profile nodes which represent the profile dependencies.
 * Returns emtpy array in case the profile does not have any dependency.
 *
 * @return Array of strings representing the references to dependent profiles
 */
function getProfileDependencies(profileNode) {
	// output array
	var dependencyNodes = new Array();

	var dependNodes = profileNode.selectNodes("depends");
	if (dependNodes != null) {
		for (var i=0; i < dependNodes.length; i++) {
			var dependencyId = dependNodes[i].getAttribute("profile-id");

			// convert dependency to lower case if case-sensitive mode is off
			if (dependencyId != null && !isCaseSensitive()) {
				dependencyId = dependencyId.toLowerCase();
			}

			// get the profile node
			var dependencyNode = getProfileNode(dependencyId);
			if (dependencyNode != null) {
				dependencyNodes.push(dependencyNode);
			} else {
				error("Profile '" + dependencyId + "' referenced but not " +
						"found. Ignoring profile.");
			}
		}
	}

	return dependencyNodes;
}

/**
 * Returns the corresponding profile ID stored within the given profile XML
 * node.
 *
 * @return String representing the ID of the supplied profile node.
 */
function getProfileID(profileNode) {
	return profileNode.getAttribute("id");
}

/**
 * Returns an array of strings which represents the profiles direcly referenced
 * by the applying host node. The profiles are evaluated as follows:
 * - /profile:<profile> parameter
 * - /host:<hostname> parameter matching within hosts.xml
 * - profiles defined within host.xml which are assigned to the matching hosts entry
 *
 * @return array of strings representing the referenced profiles
 */
function getProfileList() {
	if (profilesApplying == null) {
		// get arguments
		var argn = getArgv().Named;

		// Set the profile from either the command line or the hosts file.
		if (argn("profile") != null) {
			profilesApplying = new Array();
			profilesApplying.push(argn("profile"));
		} else {
			profilesApplying = getHostProfiles(getHostNode());

			if (profilesApplying.length <= 0) {
				throw new Error("Could not find any profile for host " + getHostname() + ".");
			}
		}
	}
	return profilesApplying;
}

/**
 * Returns the corresponding profile XML node from the profile database
 * (profilex.xml). Returns null in case no such profile exists.
 *
 * @param profileID String representation of profile to get the node from.
 */
function getProfileNode(profileID) {
	// get first node which mached the specified ID
	return getProfiles().selectSingleNode("profile[@id='" + profileID +"']");
}

/**
 * Returns an array of all profile nodes available.
 *
 * @return array of profile XML nodes.
 */
function getProfileNodes() {
	// Retrieve packages.
	var profileNodes = getProfiles().selectNodes("profile");

	// make sure a package ID exists only once
	profileNodes = uniqueAttributeNodes(profileNodes, "id");

	// return this array
	return profileNodes;
}

/**
 * Returns an array of strings which contains a list of package IDs referenced
 * by the currently applied profile.
 *
 * The list will contain all referenced IDs within profile.xml which apply to
 * the current profile(s) (including profile dependencies). Packages which are
 * referenced but do not exist within the package database (packages.xml) are
 * included as well. So be aware that in case of inconsistency between
 * profiles.xml and packages.xml it might be possible that the returned list
 * refers to packages not available within packages.xml.
 *
 * NOTE: The list does NOT contain IDs of package dependencies. Just the list
 * of packages as refered in profiles.xml. Dependency information is only
 * available within the concrete package nodes within packages.xml. Refer to
 * getProfilePackageNodes() to get packages including dependencies.
 *
 * If you like to get a list of full package nodes have a look at
 * getProfilePackageNodes() but note that it cannot return full nodes for
 * packages referenced within profiles.xml but missing in the package database.
 *
 * @return array of package IDs applying to this profile (empty array if no packages are assigned).
 */
function getProfilePackageIDs() {
	// Get array of all profiles that apply to the base profile.
	// This includes depending profiles
	var profileArray = getProfilesApplying();

	// Create array to store all referenced package IDs
	var packageIDs = new Array();

	// new date object, used for install/uninstal date comparison
	var now = new Date();

	// Add each profile's package IDs to the array.
	for (var i=0; i < profileArray.length; i++) {
		profileNode = profileArray[i];

		// Search for package tags in each profile.
		var packageNodes = profileNode.selectNodes("package");

		// Add all package IDs to the array and avoid duplicates
		for (var j = 0; j < packageNodes.length; j++) {
			// get package ID
			var packageNode = packageNodes[j];
			var packageId = packageNode.getAttribute("package-id");
			// use package methods for profile package node because the attribute it the same
			var installDate = getProfilePackageInstallDate(packageNode);
			var uninstallDate = getProfilePackageUninstallDate(packageNode);
			var includePackage = true;

			// check if the package should be included
			if (installDate != null || uninstallDate != null) {
				// eiter install or uninstall date was defined
				if (now >= installDate &&
					now <= uninstallDate) {
					includePackage = true;
					dinfo("Package'" + packageId + "' specified an install date range: " +
						installDate + " to " + uninstallDate +
						"; current time (" + now + ") is within the time frame. Including package.");
				} else {
					includePackage = false;
					dinfo("Package '" + packageId + "' specified an install date range: " +
						installDate + " to " + uninstallDate +
						"; out of range, skipping package (local time: " + now + ").");
				}
			}

			// covert to lower case if case should be ignored
			if (includePackage &&
				packageId != null &&
				!isCaseSensitive()) {
				packageId = packageId.toLowerCase();
			}

			// Search array for pre-existing ID, we don't want duplicates.
			if (includePackage) {
				var alreadyAdded = false;
				for (var k=0; k < packageIDs.length; k++) {
					if (packageIDs[k] == packageId) {
						alreadyAdded = true;
						break;
					}
				}
			}
			if (includePackage && !alreadyAdded) {
				packageIDs.push(packageId);
			}
		}
	}

	return packageIDs;
}

/**
 * Returns date object reflecting installation date defined in given node
 * @param packageNode the package definition node as specified within the profile definition
 * @return date object representing installation date
 */
function getProfilePackageInstallDate(packageNode) {
	var installDate = null;
	var packageInstallDate = packageNode.getAttribute("installdate");
	if (packageInstallDate != null) {
		installDate = parseISODate(packageInstallDate, false);
	}
	return installDate;
}

/**
 * Returns an array of package nodes that should be applied to the current
 * profile. This function returns full package nodes.
 * NOTE: Since the profile just contains the package IDs packages referenced
 * within profiles.xml but not existing within the packages database
 * (packages.xml) will not be part of the list.
 *
 * In case you like to get a list of package IDs referenced by the profile
 * (regardless if the package definition exists) have a look at
 * getProfilePackageIDs().
 *
 * @return array of packagenodes applying to the assigned profile(s)
 */
function getProfilePackageNodes() {
	if (profilePackageNodes == null) {
		// Create a new empty package array.
		var profilePackageNodes = new Array();

		/* get package IDs which apply to the profile (without dependencies,
		 * includes and chaned packages) regardless if the package definition
		 * is available or not.
		 */
		var packageIDs = getProfilePackageIDs();

		// get package definitions and all dependencies
		for ( var i = 0; i < packageIDs.length; i++) {
			var packageID = packageIDs[i];
			dinfo("Adding package with ID '" + packageID + "' to profile packages.");
			var packageNode = getPackageNodeFromAnywhere(packageID);

			// add dependencies first
			if (packageNode != null) {
				getPackageReferences(packageNode, profilePackageNodes);
				if (!searchArray(profilePackageNodes, packageNode)) {
					// Add the new node to the array _after_ adding dependencies.
					profilePackageNodes.push(packageNode);
				}
			}
		}
	}
	return profilePackageNodes;
}

/**
 * Returns Date representation of 'uninstalldate' attribute from the given
 * package definition as specified within the profile.
 * 
 * @param packageNode the package node to read the 'uinstalldate'
 *        attribute from
 * @return Date object representing uninstall date of the given package.
 *         Returns null in case the 'uninstalldate' attribute is not set.
 */
function getProfilePackageUninstallDate(packageNode) {
	var uninstallDate = null;
	var packageUninstallDate = packageNode.getAttribute("uinstalldate");
	if (packageUninstallDate != null) {
		uninstallDate = parseISODate(packageUninstallDate, true);
	}
	return uninstallDate;
}

/**
 * Returns XML node which contains all profiles (profile database).
 */
function getProfiles() {
	if(profiles == null) {
		var newProfiles = createProfiles();
		setProfiles(newProfiles);
	}
	return profiles;
}

/**
 * Returns an array of profile nodes that should be applied to the current
 * profile. This includes also all profile dependencies.
 *
 * @return array of profiles (directly associated profiles and dependencies)
 */
function getProfilesApplying() {
	dinfo("Getting profiles which apply to this node.");
	if (applyingProfiles == null) {
		// create cache entry
		applyingProfiles = new Array();

		// get list of applying profiles
		var profileList = getProfileList();

		for (var i=0; i<profileList.length; i++) {
			// receive profile node
			var profileNode = getProfileNode(profileList[i]);

			if (profileNode != null) {
				dinfo("Applying profile: " + getProfileID(profileNode));

				// Add the current profile's node as the first element in the array.
				applyingProfiles.push(profileNode);

				appendProfileDependencies(applyingProfiles, profileNode);
			} else {
				error("Profile '" + profileList[i] + "' applies to this host but was not found!");
			}
		}
	}
	return applyingProfiles;
}

/**
 * Returns the log level associated with a given profile.
 *
 * @return merged log levels from all applying profiles. For example if one
 * 		profile specifies info loging and a second profile specifies error. The
 * 		resulting log level will be info+error.
 * 		Returns null if no custom log level is specified for this profile.
 */
function getProfilesLogLevel() {
	// set initial bitmask to 0x00;
	var logLevel = 0x00;

	// merge log levels
	var profileList = getProfileList();
	for (var i=0; i<profileList.length; i++) {
		var profileId = profileList[i];
		var profileNode = getProfileNode(profileId);
		if (profileNode != null) {
			// add bitmask
			logLevel = logLevel | profileNode.getAttribute("logLevel");
		}
	}
	if (logLevel > 0x00) {
		return logLevel;
	} else {
		return null;
	}
}

/**
 * Returns a list of variables from the Profile.
 *
 * @param dictionary Dictionary of type Scripting.Dictionary to which the the
 *        variables are written to (existing values are overwritten).
 *        In case null is supplied it returns a new dictionary object.
 * @return Object of type Scripting.Dictionary which contains all key/value
 *         pairs from the given profile including its dependencies
 */
function getProfileVariables(dictionary) {
	dinfo("Reading variables from profile[s]");
	var profileArray = getProfilesApplying();
	dinfo(profileArray.length + " profiles apply to this host.");

	var variables;
	// make sure variables is either assigned or created
	if (dictionary == null) {
		variables = new ActiveXObject("Scripting.Dictionary");
	} else {
		variables = dictionary;
	}

	/* add each profile's variables to the array in reverse order
	 * reversing the order is done in order to allow overwriting
	 * of variables from dependent profiles
	 */
	for (var i=profileArray.length-1; i >= 0; i--) {
		var profileNode = profileArray[i];
		dinfo("Reading variables from profile " + getProfileID(profileNode));

		variables = getVariables(profileNode, variables);
	}

	return variables;
}

/**
 * Returns the corresponding package XML node from the settings database
 * (wpkg.xml). Returns null in case no such package is installed.
 */
function getSettingNode(packageID) {
	// get first node which mached the specified ID
	return getSettings().selectSingleNode("package[@id='" + packageID +"']");
}

/**
 * Returns an array of all installed packages from the local wpkg.xml
 *
 * @return Array of installed packages (XML nodes)
 */
function getSettingNodes() {
	// retrieve packages
	var packageNodes = getSettings().selectNodes("package");

	// make sure a package ID exists only once
	// commented since the local database should not contain duplicated entries
	packageNodes = uniqueAttributeNodes(packageNodes, "id");

	// return this array
	return packageNodes;
}

/**
 * Returns XML node which contains all settings (local package database).
 */
function getSettings() {
	if(settings == null) {
		var newSettings = createSettings();
		setSettings(newSettings);
	}
	return settings;
}

/**
 * Returns a list of package nodes (Array object) which have been scheduled
 * for removal but are not removed due to the /noremove flag.
 *
 * @return Array of package nodes which would have been removed during this session
 */
function getSkippedRemoveNodes() {
	if (skippedRemoveNodes == null) {
		skippedRemoveNodes = new Array();
	}
	return skippedRemoveNodes;
}

/**
 * Returns a list of key/value pairs representing all variable definitions from
 * the given XML node.
 *
 * @param XMLNode The XML node to get the variables from
 * @param dictionary Dictionary of type Scripting.Dictionary to which the the
 *        variables are written to (existing values are overwritten).
 *        In case null is supplied it returns a new dictionary object.
 * @return Object of type Scripting.Dictionary which contains all key/value
 *         pairs from the given XML node.
 */
function getVariables(XMLNode, dictionary) {
	// a new empty array of variables
	var variables;

	// make sure variables is either created or assigned
	if(dictionary == null) {
		variables = new ActiveXObject("Scripting.Dictionary");
	} else {
		variables = dictionary;
	}

	// create a shell to expand variables immediately
	var shell = new ActiveXObject("WScript.Shell");
	var variableNodes = XMLNode.selectNodes("variable");
	for (var i=0; i < variableNodes.length; i++) {
		var variableName = variableNodes[i].getAttribute("name");
		var variableValue = variableNodes[i].getAttribute("value");
		variableValue = shell.ExpandEnvironmentStrings(variableValue);
		dinfo("Got variable '" + variableName + "' of value '" + variableValue + "'");

		// remove eventually existing variable
		// I don't like to use
		// variables.Item(variableName)=variableValue;
		// because my IDE/parser treats it as an error:
		// "The left-hand side of an assignment must be a variable"
		try {
			variables.Remove(variableName);
		} catch(e) {
			dinfo("Variable '" + variableName + "' was not defined before. Creating now.");
		}
		try {
			variables.Add(variableName, variableValue);
		} catch(e) {
			var message = "Variable '" + variableName + "' of value '" + variableValue + "'" +
				" could not be assigned to dictionary!";
			if (isQuitOnError()) {
				throw new Error(message);
			}
			error(message);
		}
	}

	return variables;
}

/**
 * Installs the specified package node to the system.
 * If an old package node is supplied performs an upgrade. In case the old
 * package node is null an installation is performed.
 *
 */
function installPackage(packageNode) {
	// return value
	var success = false;

	var packageName = getPackageName(packageNode);
	var packageID   = getPackageID(packageNode);
	var packageRev  = getPackageRevision(packageNode);
	var executeAttr = getPackageExecute(packageNode);
	var notifyAttr  = getPackageNotify(packageNode);
	var rebootAttr  = getPackageReboot(packageNode);

	dinfo("Going to install package '" + packageName + "' (" + packageID +
		"), Revision " + packageRev + ", (execute flag is '" + executeAttr +
		"', notify flag is '" + notifyAttr + "').");


	 // search for the package in the local settings
	var installedPackage = getSettingNode(packageID);

	// if set then the package installation will be bypassed
	var bypass = false;
	// type of installation "install" or "upgrade"
	var typeInstall = "install";
	var typeUpgrade = "upgrade";
	var typeDowngrade = "downgrade";
	var installType = typeInstall;

	// string to print in events which identifies the package
	var packageMessage = "Package '" + packageName + "' (" + packageID + ")" +
						": ";

	// check if the package has been executed already
	if(searchArray(packagesProcessed, packageNode)) {
		// has been installed already during this session
		dinfo(packageMessage +
				"Already installed once during this session.\n" +
				"Checking if package is properly installed.");
		bypass=true;

		// check if installation of package node was successful
		if ((installedPackage != null) &&
			(versionCompare(getPackageRevision(installedPackage), packageRev) >= 0)) {
			// packege successfully installed
			dinfo(packageMessage + "Verified; " +
				"package successfully installed during this session.");

			success = true;

		} else {
			dinfo(packageMessage +
				"Installation failed during this session.");
			// package installation must have been failed

			success = false;

		}
	} else {
		// mark package as processed
		packagesProcessed.push(packageNode);

		dinfo(packageMessage + "Not yet processed during this session.");
		bypass = false;
		// evaluate what do do with the package

		if (executeAttr == "always") {
			// ALWAYS EXECUTION PACKAGE
			/* packages with exec attribute "always" will be installed on each
			 * turn regardless of their version.
			 */
			bypass = false;
			installType = typeInstall;
			dinfo(packageMessage + "Prepared for installation.");

		} else {
			// evaluate type of installation (install/upgrade/skip)
			// install
			if (installedPackage == null) {
				// ONE-TIME INSTALL PACKAGE, NOT INSTALLED YET (according to settings)
				// install the package after checking that it is not installed already
				/* there is a slight chance that the package check of a new package
				 * returns true in case an old package is installed. In such case the
				 * package will be marked as "installed" immediately. Next update will
				 * update it to the new version then.
				 */
				dinfo(packageMessage + "Not in local package database.");

				if (isInstalled(packageNode)) {
					info(packageMessage +
						"Already installed (checks succeeded). Checking dependencies and chained packages.");

					// mark package as processed
					// note: do this before dependency processing to avoid problems
					// if a dependency includes this package again.
					packagesProcessed.push(packageNode);

					// append new node to local xml
					addSettingsNode(packageNode);

					// install all dependencies
					var depSuccess = installPackageReferences(packageNode, "dependencies");
					if (depSuccess) {
						info(packageMessage +
							 "Package and all dependencies are already installed. Skipping.");

					} else {
						info(packageMessage +
							"Installed but at least one dependency is missing.");
					}

					// install all chained packages
					var chainedSuccess = installPackageReferences(packageNode, "chained");
					if (chainedSuccess) {
						info(packageMessage +
							 "Package and all chained packages are already installed. Skipping.");

					} else {
						info(packageMessage +
						"Installed but at least one chained package is missing.");
					}
					
					bypass = true;
					installType = typeInstall;

					// still set success to true since the package seems to be
					// installed properly (check succeed)
					success = true;

				} else {
					// package not installed
					bypass = false;
					success = false;
					installType = typeInstall;
					info(packageMessage +
						"Not installed (checks failed). Preparing installation.");
				}

			// upgrade
			} else if (versionCompare(packageRev, getPackageRevision(installedPackage)) > 0) {
				// ONE-TIME INSTALL PACKAGE, NEW REVISION
				info(packageMessage +
					"Already installed but version mismatch.\n" +
					"Installed revision: '" + getPackageRevision(installedPackage) + "'\n" +
					"Available revision: '" + packageRev + "'.\n" +
					"Preparing upgrade."
					);
				// package needs to be upgraded
				bypass = false;
				success = false;
				installType = typeUpgrade;

			// downgrade
			} else if (versionCompare(packageRev, getPackageRevision(installedPackage)) < 0) {
				// ONE-TIME INSTALL PACKAGE, DOWNGRADE
				info(packageMessage +
					"Already installed but version mismatch.\n" +
					"Installed revision '" + getPackageRevision(installedPackage) + "'\n" +
					"Available revision: '" + packageRev + "'.\n" +
					"Preparing downgrade."
					);
				// package needs to be downgraded
				bypass = false;
				success = false;
				installType = typeDowngrade;

			// skip in case of execute=once, otherwise check.
			} else {
				// ONE-TIME INSTALL PACKAGE, ALREADY INSTALLED

				if (isForceInstall()) {
					// if installation is forced, install anyway
					info(packageMessage + "Already installed. Forcing re-installation");
					bypass = false;
					success = false;
					installType = typeInstall;
				} else {
					// if execute is 'once' then package checks are not executed. We just
					// trust that the package is installed
					if (executeAttr == "once") {
						dinfo(packageMessage + "Installed already.");
						bypass = true;
						success = true;
						installType = typeUpgrade;
					} else {
						// in case the no execution attribute is defined
						// ckeck real package state
						if (isInstalled(installedPackage)) {
							dinfo(packageMessage + "Already installed. Skipping.");
							bypass = true;
							success = true;
							installType = typeUpgrade;
						} else {
							// package not installed
							dinfo(packageMessage + "Installed but checks failed. Re-Installing.");
							bypass = false;
							success = false;
							installType = typeInstall;
						}
					}
				}
			}
		}
	}

	if (!bypass) {
		if (notifyAttr) {
			// notify user about start of installation
			notifyUserStart();
		}
		try {
			// install dependencies
			var depInstallSuccess = installPackageReferences(packageNode, "dependencies");

			// abort installation in case dependencies could not be installed
			if (!depInstallSuccess) {
				throw new Error("Installing dependencies failed");
			}

			// print event log entry
			info("Installing '" + packageName + "' (" + packageID + ")...");

			// stores if the package needs a reboot after installation
			var rebootRequired = false;

			// stores if the package needs a reboot after installing all packages
			var rebootPostponed = false;

			// Generate the correct environment.

			// set package specific environment
			loadPackageEnv(packageNode);

			// Select command lines to install.
			var cmds;
			dinfo("Install type: " + installType);
			if (installType == typeUpgrade) {
				// installation is an upgrade
				cmds = getPackageCmdUpgrade(packageNode);
				dinfo("Fetched " + cmds.length + " upgrade command(s).");
			} else if (installType == typeDowngrade) {
				// prepare downgrade
				cmds = getPackageCmdDowngrade(packageNode);
				dinfo("Fetched " + cmds.length + " downgrade command(s).");
			}else {
				// installation is default
				cmds = getPackageCmdInstall(packageNode);
				dinfo("Fetched " + cmds.length + " install command(s).");
			}

			// download files (if any)
			var downloadNodes = getDownloads(packageNode, null);
			// append command downloads
			for (var iCommands = 0; iCommands < cmds.length; iCommands++) {
				var commandNode = cmds[iCommands ];
				getDownloads(commandNode, downloadNodes);
			}

			// download all specified downloads
			var downloadResult = downloadAll(downloadNodes);
			if (downloadResult != true) {
				var failureMessage = "Failed to download all files.";
				if (isQuitOnError()) {
					throw new Error(failureMessage);
				} else {
					error(failureMessage);
				}
			}

			// execute each command line
			for (var iCmd = 0; iCmd < cmds.length; iCmd++) {
				var cmdNode = cmds[iCmd];
				var cmd = getCommandCmd(cmdNode);
				var timeout = getCommandTimeout(cmdNode);
				var workdir = getCommandWorkdir(cmdNode);

				var result = 0;
				result = exec(cmd, timeout, workdir);

				// search for exit code
				var exitAction = getCommandExitCodeAction(cmdNode, result);

				// check for special exit codes
				if (exitAction != null) {
					if (exitAction == "reboot") {
						// This exit code forces a reboot.
						info("Command in installation of " + packageName +
							" returned exit code [" + result + "]. This " +
							"exit code requires an immediate reboot.");
						reboot();
					} else if (exitAction == "delayedReboot") {
						// This exit code schedules a reboot
						info("Command in installation of " + packageName +
							" returned exit code [" + result + "]. This " +
							"exit code schedules a reboot.");
						// schedule reboot
						rebootRequired = true;
						// proceed with next command
						continue;
					} else if (exitAction == "postponedReboot") {
						info("Command in installation of " + packageName +
							" returned exit code [" + result + "]. This " +
							"exit code schedules a postponed reboot.");
						rebootPostponed = true;
						setPostponedReboot(rebootPostponed);
						// execute next command
						continue;
					} else {
						// this exit code is successful
						info("Command in installation of " + packageName +
							" returned exit code [" + result + "]. This " +
							"exit code indicates success.");
						// execute next command
						continue;
					}
				} else if(result == 0) {
					// if exit code is 0, return success
					// execute next command
					dinfo("Command in installation of " + packageName +
						" returned exit code [" + result + "]. Success.");
					continue;
				} else {
					// command did not succeed, throw an error
					throw new Error("Exit code returned non-successful value (" +
							result + ") on command '" + cmd + "'");
				}
			}

			// packages with checks have to pass the isInstalled() test
			if (getPackageChecks(packageNode).length > 0 && !isInstalled(packageNode)) {
				// package failed for now
				success = false;

				// check if a delayed reboot has been scheduled
				// if reboot is scheduled it might be OK if the package check fails
				if (rebootRequired || rebootAttr == "true") {
					warning("Package processing (" + installType + ") failed for package " +
						packageName + ".\nHowever the package requires a reboot to complete. Rebooting.");
					// reboot system without adding to local settings yet
					reboot();
				} else if (rebootPostponed || rebootAttr == "postponed") {
					warning("Package processing (" + installType + ") failed for package " +
						packageName + ".\nHowever the package schedules a postponed reboot.");
				} else {
					// package installation failed
					var failMessage = "Could not process (" + installType + ") " + packageName + ".\n" +
								"Failed checking after installation.";
					if (isQuitOnError()) {
						throw new Error(failMessage);
					} else {
						error(failMessage);
					}
				}
			} else {
				success = true;
				// append new node to local xml
				addSettingsNode(packageNode);
				
				// install chained packages
				var chainedStatus = installPackageReferences(packageNode, "chained");
				if (chainedStatus) {
					info(packageMessage +
						 "Package and all chained packages installed successfully.");

				} else {
					info(packageMessage +
					"Package installed but at least one chaned package failed to install.");
				}
				
				// Reboot the system if needed.
				if (rebootRequired || rebootAttr == "true") {
					info("Installation of " + packageName + " successful, system " +
						"rebooting.");
					reboot();
				} else if (rebootPostponed || rebootAttr == "postponed") {
					info("Installation of " + packageName + " successful, postponed reboot scheduled.");
					setPostponedReboot(true);
				} else {
					info("Processing (" + installType + ") of " + packageName + " successful.");
				}
			}
		} catch (err) {
			success = false;
			var errorMessage = "Could not process (" + installType + ") package '" +
							 packageName + "' (" + packageID + "):\n" + err.description + ".";
			if (isQuitOnError()) {
				throw new Error(errorMessage);
			} else {
				error(errorMessage);
			}
		} finally {
			// cleaning up temparary downloaded files
			dinfo("Cleaning up temporary downloaded files");
			// clean downloads
			downloadsClean(downloadNodes);
			
			// restore old environment
			dinfo("Restoring previous environment.");
			// restore previous environment
			loadEnv();
		}
	}
	return success;
}

 /**
  * Installs all packages references of the selected type.
  * Returns true in case all references  could be installed.
  * Returns false if at least one reference failed.
  *
  * @param packageNode package to install the references of (XML node)
  * 				NOTE: The package itself is not installed.
  * @param refrerenceType select "dependencies" or "chained".
  * 		Defaults to "dependencies".
  * @return true=all dependencies installed successful;
  *         false=at least one dependency failed
  */
 function installPackageReferences(packageNode, referenceType) {
 	var problemDesc = "";
 	var refSuccess = true;

 	// get references
 	var type;
 	var references = new Array();
 	switch (referenceType) {
	case "chained":
		type = "chained";
	 	references = getPackageChained(packageNode, null);
		break;

	default:
		type = "dependencies";
		references = getPackageDependencies(packageNode, null);
		break;
	}
 	if (references.length > 0) {
 		info("Installing references (" + type + ") of '" +
 				getPackageName(packageNode) +
 				"' (" + getPackageID(packageNode) + ").");
 	}
 	for (var i=0; i < references.length; i++) {
 		var refPackage = getPackageNodeFromAnywhere(references[i]);
 		if (refPackage == null) {
 			problemDesc += "Package references '" + references[i] +
 						"' but no such package exists";
 			refSuccess = false;
 			break;
 		} else {
 			// install this package
 			var success = installPackage(refPackage);
 			if (!success) {
 				problemDesc += "Installation of reference (" + type + ") package '"
 					+ getPackageName(refPackage) + "' ("
 					+ getPackageID(refPackage) + ") failed";
 				refSuccess = false;
 				// skip remaining references
 				break;
 			}
 		}
 	}
 	if (refSuccess) {
 		var successMessage = "Installation of references (" + type + ") for '" +
 						 getPackageName(packageNode) + "' (" +
 						 getPackageID(packageNode) + ") successfully finished.";
 		dinfo(successMessage);
 	} else {
 		var failMessage = "Installation of references (" + type + ") for '" +
 						 getPackageName(packageNode) + "' (" +
 						 getPackageID(packageNode) + ") failed. " + problemDesc;
 		if (isQuitOnError()) {
 			throw new Error(failMessage);
 		} else {
 			error(failMessage);
 		}
 	}

 	return refSuccess;
 }


/**
 * Installs a package by name.
 */
function installPackageName(name) {
	// Query the package node.
	var node = getPackageNode(name);

	if (node == null) {
		info("Package " + name + " not found!");
		return;
	}

	 installPackage(node);
}

/**
 * Returns true if running on a 64-bit system. False if running on a 32-bit
 * system.
 * Please note that WPKG needs to be run from the local 64-bit cscript instance
 * in order to be able to access 64-bit directories and registry keys.
 * The 64-bit instance of cscript is located at %SystemRoot%\system32\. If
 * cscript from %SystemRoot%\SysWOW64\ is used (32-bit binary) then all reads
 * to %ProgramFiles% will be redirected to %ProgramFiles(x86). Hence it is not
 * possible for WPKG to access the "real" %ProgramFiles% folder with the 64-bit
 * binaries. The same applies for the registry. If 32-bit cscript is used all
 * reads to HKLM\Software\* are redirected to HKLM\Software\Wow6432Node\*.
 *
 * WARNING: If cscript is invoked from a 32-bit application it is not possible
 * to run the 64-bit version of cscript since the real %SystemRoot%\System32
 * directory is not visible to 32-bit applications. So Windows will invoke the
 * 32-bit version even if the full path is specified!
 *
 * A work-around is to copy the 64-bit cmd.exe from %SystemRoot%\System32
 * manually to a temporary folder and invoke it by using
 * c:\path\to\64-bit\cmd.exe /c \\path\to\wpkg.js
 *
 * @return true in case the system is running on a 64-bit Windows version.
 *         otherwise false is returned.
 */
function is64bit() {
	if (x64 == null) {
		var wshObject = new ActiveXObject("WScript.Shell");
		// check if PROCESSOR_ARCHITECTURE is AMD64
		// NOTE: On 32-bit systems PROCESSOR_ARCHITECTURE is x86 even if the CPU is
		// actually a 64-bit CPU
		var architecture = wshObject.ExpandEnvironmentStrings("%PROCESSOR_ARCHITECTURE%");
		if (architecture == "AMD64") {
			x64 = true;
		} else {
			x64 = false;
		}
	}
	return x64;
}

/**
 * returns current state of case sensitivity flag
 * @return true if case case sensitivity is enabled,
 * 			false if it is diabled (boolean)
 */
function isCaseSensitive() {
	return caseSensitivity;
}

/**
 * Returns current debug status.
 *
 * @return true if debug state is on, false if debug is off
 */
function isDebug() {
	return debug;
}

/**
 * Returns current dry run status.
 *
 * @return true if dry run state is on, false if dry run is off
 */
function isDryRun() {
	return dryrun;
}

/**
 * Returns current value of the force flag.
 *
 * @return true if force is enabled, false if it is disabled (boolean).
 */
function isForce() {
	return force;
}

/**
 * Returns current value of the forceinstall flag.
 *
 * @return true if forced installation is enabled, false if it is disabled (boolean).
 */
function isForceInstall() {
	return forceInstall;
}

/**
 * Returns if log should be appended or overwritten
 *
 * @return true in case log should be appended. false if it should be
 * 		overwritten (boolean).
 */
function isLogAppend() {
	return logAppend;
}

/**
 * Check if package is installed.
 *
 * @return returns true in case the package is installed, false otherwise
 * @throws Error in case checks could not be evaluated
 */
function isInstalled(packageNode) {
	var packageName = getPackageName(packageNode);
	var result = true;

	dinfo ("Checking existence of package: " + packageName);

	// Get a list of checks to perform before installation.
	var checkNodes = getPackageChecks(packageNode);

	// When there are no check conditions, say "not installed".
	if (checkNodes.length == 0) {
		return false;
	}

	// save current environment
	saveEnv();
	// load package specific environment
	loadPackageEnv(packageNode);

	// Loop over every condition check.
	// If all are successful, we consider package as installed.
	for (var i = 0; i < checkNodes.length && result != false; i++) {
		try {
			if (!checkCondition(checkNodes[i])) {
				result = false;
			}
		} catch (err) {
			message = "Error evaluating package check for package '" + packageName +
						"': " + err.description;
			if (isQuitOnError()) {
				// restore environment
				loadEnv();
				throw new Error(message);
			} else {
				error(message);
				result = false;
			}
		}
	}
	// restore environment
	loadEnv();

	return result;
}

/**
 * Returns current status of /forceremove parameter
 *
 * @return true in case forced remove is enabled, false if it is disabled
 */
function isNoForcedRemove() {
	return noForcedRemove;
}

/**
 * Returns if the nonotify flag is set or not.
 *
 * @return true if nonotify flag is set, false if nonotify is not set (boolean)
 */
function isNoNotify() {
	return nonotify;
}

/**
 * Returns if the noreboot flag is set or not.
 *
 * @return true if noreboot flag is set, false if noreboot is not set (boolean)
 */
function isNoReboot() {
	return noreboot;
}

/**
 * Returns the current state (boolean) of the noremove flag.
 *
 * @return true if noremove flag is set, fals if noremove is not set (boolean)
 */
function isNoRemove() {
	return noRemove;
}

/**
 * Returns if the noRuningState flag is set or not.
 *
 * @return true if noRunningState flag is set, false if noRunningState is not set (boolean)
 */
function isNoRunningState() {
	return noRunningState;
}

/**
 * Returns the current state of postponed reboots. If it returns true a reboot
 * is scheduled when the script exits (after completing all actions).
 *
 * @return current status of postponed reboot (boolean)
 */
function isPostponedReboot() {
	return postponedReboot;
}

/**
 * Returns current value of the sendStatus flag
 *
 * @return true in case status schould be sent, otherwise returns false
 */
function isSendStatus() {
	return sendStatus;
}

/**
 * Returns the current value of the upgrade-before-remove feature flag.
 * 
 * @return true in case upgrade-before-remove should be enabled, otherwise returns false.
 */
function isUpgradeBeforeRemove() {
	return !noUpgradeBeforeRemove;
}

/**
 * Returns current value of skip event log setting.
 *
 * @return true in case event log logging is enabled, false if it is disabled (boolean).
 */
function isSkipEventLog() {
	return skipEventLog;
}

/**
 * Returns true if quiet mode is on. False otherwise.
 *
 * @return true if quiet flag is set, false if it is unset (boolean)
 */
function isQuiet() {
	return quietMode;
}

/**
 * Returns current value of quit on error setting (see '/quitonerror' parameter)
 *
 * @return true in case quit on error is enabled, false if it is disabled (boolean).
 */
function isQuitOnError() {
	return quitonerror;
}

/**
 * Checks if a package is a zombie package which means that it exists within
 * the locale package database (wpkg.xml) but not on server database
 * (packages.xml)
 * @return true in case the package is a zombie, false otherwise
 */
function isZombie(packageNode) {
	var packageName = getPackageID(packageNode);
	var allPackagesArray = getPackageNodes();
	var zombie = true;
	dinfo("Checking " + packageName + " zombie state.");
	for (var i=0; i < allPackagesArray.length; i++) {
		if (getPackageID(allPackagesArray[i]) == packageName) {
			zombie = false;
			break;
		}
	}

	// print message for zombie packages
	if (zombie) {
		var errorMessage = "Error while synchronizing package " + packageName +
		"\nZombie found: package installed but not in packages database.";
		if (isQuitOnError()) {
			errorMessage += " Aborting synchronization.";
			error(errorMessage);
			throw new Error(errorMessage);
		} else {
			errorMessage += " Removing package.";
			error(errorMessage);
		}
	}

	return zombie;
}

/**
 * Queries all available packages (from package database and local settings)
 * and prints a quick summary.
 */
function queryAllPackages() {
	// Retrieve packages.
	var settingsNodes = getSettingNodes();
	var packagesNodes = getPackageNodes();

	// Concatenate both lists.
	var packageNodes = concatenateList(settingsNodes, packagesNodes);
	packageNodes = uniqueAttributeNodes(packageNodes, "id");

	// Create a string to append package descriptions to.
	var message = "All available packages (" + packageNodes.length + "):\n";

	// query all packages
	for (var i = 0; i < packageNodes.length; i++) {
		message += queryPackage(packageNodes[i]) + "\n\n";
	}

	info(message);
}

/**
 * Show the user a list of packages that are currently installed.
 */
function queryInstalledPackages() {
	// Retrieve currently installed nodes.
	var packageNodes = getSettingNodes();

	// Create a string to append package descriptions to.
	var message = "Packages currently installed:\n";

	for (var i = 0; i < packageNodes.length; i++) {
		message += queryPackage(packageNodes[i]) + "\n\n";
	}

	info(message);
}

/**
 * Show the user information about a specific package.
 *
 * @param packageNode the package node to print information of
 * @return string representing the package information
 */
function queryPackage(packageNode) {
	var message = "";
	if (packageNode != null) {
		message = getPackageName(packageNode) + "\n";
		message += "    ID:          " + getPackageID(packageNode) + "\n";
		message += "    Revision:    " + getPackageRevision(packageNode) + "\n";
		message += "    Reboot:      " + getPackageReboot(packageNode) + "\n";
		message += "    ExecAttribs: " + getPackageExecute(packageNode) + "\n";
		var settingNode = getSettingNode(getPackageID(packageNode));
		if (settingNode != null && getPackageID(settingNode) == getPackageID(packageNode)) {
			message += "    Status:      Installed\n";
		} else {
			message += "    Status:      Not Installed\n";
		}
	} else {
		message += "No such package\n";
	}

	return message;
}

/**
 * Shows the user a list of packages that are currently not installed.
 */
function queryUninstalledPackages() {
	// create a string to append package descriptions to
	var message = "Packages not installed:\n";

	// get list of all available packages from package database
	var packageNodes = getPackageNodes();

	// check for each package if it is installed
	for (var i = 0; i < packageNodes.length; i++) {
		if (getSettingNode(getPackageID(packageNodes[i])) == null) {
			message += queryPackage(packageNodes[i]) + "\n\n";
		}
	}
	info(message);
}

/**
 * Show the user a list of packages that can be updated.
 */
function queryUpgradablePackages() {
	// Retrieve currently installed and installable nodes.
	var installedNodes = getSettingNodes();
	var availableNodes = getPackageNodes();

	// Create a string to append package descriptions to.
	var message = "";

	for (var i = 0; i < installedNodes.length; i++) {
		var installedNode       = installedNodes[i];
		var instPackageId       = getPackageID(installedNode);
		var instPackageRevision = getPackageRevision(installedNode);
		var instPackageExecAttr = getPackageExecute(installedNode);
		if (instPackageExecAttr == "") {
			instPackageExecAttr = "none";
		}
		for (var j = 0; j < availableNodes.length; j++) {
			var availableNode        = availableNodes[j];
			var availPackageId       = getPackageID(availableNode);
			var availPackageRevision = getPackageRevision(availableNode);
			if (instPackageId == availPackageId) {
				if (versionCompare(availPackageRevision, instPackageRevision) > 0) {
					message += getPackageName(availableNode) + "\n";
					message += "    ID:           " + instPackageId + "\n";
					message += "    Old Revision: " + instPackageRevision + "\n";
					message += "    New Revision: " + availPackageRevision + "\n";
					message += "    ExecAttribs:  " + instPackageExecAttr + "\n";
					message += "    Status:       upgradable\n";
					message += "\n";
				}
			}
		}
	}
	info(message);
}

/**
 * Removes the specified package node from the system. This function will
 * remove all packages which depend on the one to be removed prior to the package
 * itself. In case the /force parameter is set the function will even remove the
 * requested package if not all packages depending on it could be removed. Note
 * that these packages might probably not work any more in such case.
 *
 * @param packageNode Package to be removed
 * @return True in case of successful remove of package and all packages depending on it.
 *         False in case of failed package uninstall of failed uninstall of package depending on it.
 */
function removePackage(packageNode) {
	var packageName = getPackageName(packageNode);
	var packageID = getPackageID(packageNode);

	var success = true;
	var bypass = false;

	// string to print in events which identifies the package
	var packageMessage = "Package '" + packageName + "' (" + packageID + ")" +
						": ";
	
	// check if package has been processed already
	if(searchArray(packagesRemoved, packageNode)) {
		// package has been removed during this session already
		dinfo(packageMessage +
				"Already removed once during this session.\n" +
				"Checking if package has been removed properly.");
		bypass=true;

		// check if installation of package node was successful
		var installedPackage = getSettingNode(packageID);
		if (installedPackage == null) {
			// package successfully removed
			dinfo(packageMessage + "Verified; " +
				"package successfully removed during this session.");

			success = true;

		} else {
			dinfo(packageMessage +
				"Package removal failed during this session.");
			// package removal must have failed

			success = false;
		}
	} else {
		dinfo(packageMessage + "Not yet processed during this session.")
	}

	
	if (!bypass) {
		// set package as processed in order to prevent processing multiple times
		packagesRemoved.push(packageNode);

		if (isNoRemove()) {
			var message = "Package removal disabled: ";
			// check if the package is still installed
			if (isInstalled(packageNode)) {
				// the package is installed - keep it and add to skipped nodes
				dinfo(message + "Package " + packageName +  " (" + packageID +
					") will not be removed.");
				addSkippedRemoveNodes(packageNode);
	
				// package is not effectively removed
				success = false;
			} else {
				// package not installed - remove from local settings file
				dinfo(message + "Package " + packageName +  " (" + packageID +
					") will be removed from local settings because it is not installed.");
				removeSetingsNode(packageNode);
	
				// package seems to be removed
				success = true;
			}
		} else {
			// remove dependent packages first
			var allSuccess = removePackagesDependent(packageNode);
			if (!allSuccess && !isForce()) {
				// removing of at least one dependent package failed
				var failedRemove = "Failed to remove package which depends on '"
						+ packageName + " (" + packageID + "), skipping removal.\n"
						+ "You might use the /force flag to force removal but "
						+ "remember that the package depending on this one might "
						+ "stop working.";
				success = false;
	
				if (isQuitOnError()) {
					throw new Error(0, failedRemove);
				} else {
					error(failedRemove);
				}
			} else {
				try {
					info("Removing " + packageName + " (" + packageID + ")...");
		
					// select command lines to remove
					var cmds = getPackageCmdRemove(packageNode);
		
					// stores if the package needs a reboot after removing
					var rebootRequired = false;
		
					// stores if a postponed reboot should be scheduled
					var rebootPostponed = false;
		
					// set package specific environment
					loadPackageEnv(packageNode);
		
					// execute all remove commands
					for (var iCommand = 0; iCommand  < cmds.length; iCommand++) {
						var cmdNode = cmds[iCommand ];
						var cmd = getCommandCmd(cmdNode);
						var timeout = getCommandTimeout(cmdNode);
						var workdir = getCommandWorkdir(cmdNode);
		
						notifyUserStart();
		
						var result = exec(cmd, timeout, workdir);
		
						dinfo("Command returned result: " + result);
		
						// check if there is an exit code defined
						var exitAction = getCommandExitCodeAction(cmdNode, result);
		
						// Check for special exit codes.
						if (exitAction != null) {
							if (exitAction == "reboot") {
								// This exit code forces a reboot.
								info("Command in removal of " + packageName + " returned " +
									"exit code [" + result + "]. This exit code " +
									"requires an immediate reboot.");
		
								if(isZombie(packageNode)) {
									// check if still referenced within the profile
									var profilePackageArray = getProfilePackageNodes();
									var referenceFound = false;
									for (var iPackage = 0; iPackage < profilePackageArray.length; iPackage++) {
										if (packageID == getPackageID(profilePackageArray[iPackage])) {
											referenceFound = true;
											break;
										}
									}
									// if package is a zombie and not referenced within the profile
									// remove the settings entry
									if(!referenceFound && !isNoForcedRemove()) {
										removeSetingsNode(packageNode);
										info("Removed '" + packageName + "' ("
											+ packageID + ") from local settings.\n" +
												"Package initiated immediate reboot and is a zombie.");
									}
								}
		
								reboot();
							} else if(exitAction == "delayedReboot") {
								// This exit code schedules a reboot
										info("Command in removal of " + packageName +
											" returned exit code [" + result + "]. This " +
											"exit code schedules a reboot.");
								// schedule reboot
								rebootRequired = true;
								// execute next command
								continue;
							} else if(exitAction == "postponedReboot") {
								info("Command in removal of " + packageName +
									" returned exit code [" + result + "]. This " +
									"exit code schedules a postponed reboot.");
								rebootPostponed = true;
								setPostponedReboot(rebootPostponed);
								// execute next command
								continue;
							} else {
								// This exit code is successful.
								info("Command in removal of " + packageName + " returned " +
									" exit code [" + result + "]. This exit code " +
									"indicates success.");
								continue;
							}
						} else if(result == 0) {
							// if exit code is 0, return success
							// execute next command
							dinfo("Command in removal of " + packageName +
								" returned exit code [" + result + "]. Success.");
							continue;
						} else {
							// command did not succeed, log error
							var failedCmd = "Exit code returned non-successful value: " +
								result + "\nPackage: " + packageName + ".\nCommand:\n" + cmd;
							// error occured during remove
							success = false;
		
							if (isQuitOnError()) {
								throw new Error(0, failedCmd);
							} else {
								error(failedCmd);
							}
						}
					}
				} catch (err) {
					success = false;
					var errorMessage = "Could not process (remove) package '" +
					 					packageName + "' (" + packageID + "):\n" + err.description + ".";
					if (isQuitOnError()) {
						throw new Error(errorMessage);
					} else {
						error(errorMessage);
					}
				} finally {
					// restore old environment
					dinfo("Restoring previous environment.");
	
					// restore previous environment
					loadEnv();
				}
			}
	
			// read reboot attribute
			var rebootAttr = getPackageReboot(packageNode);
	
			// Use package checks to prove if package has been removed.
			// Zombies are removed in any case (even if uninstall failed) except if the
			// "/noforcedremoval" parameter was set
			if (!isInstalled(packageNode)) {
				// Remove package node from local xml.
				removeSetingsNode(packageNode);
	
				if (rebootRequired || rebootAttr == "true") {
					info("Removal of " + packageName + " successful, system " +
						"rebooting.");
					reboot();
				} else if (rebootPostponed || rebootAttr == "postponed") {
					info("Removal of " + packageName + " successful, postponed reboot scheduled.");
				} else {
					info("Removal of " + packageName + " successful.");
				}
			} else {
				// check if package is a zombie
				if(isZombie(packageNode)) {
					// check if still referenced within the profile
					var packageArray = getProfilePackageNodes();
					var referenced = false;
					for (var i=0; i < packageArray.length; i++) {
						if (packageID == getPackageID(packageArray[i])) {
							referenced = true;
							break;
						}
					}
					// if package is a zombie and not referenced within the profile
					// remove the settings entry
					if(!referenced && !isNoForcedRemove()) {
						removeSetingsNode(packageNode);
						warning("Errors occurred while removing '" + packageName + "' ("
							+ packageID + ").\nPackage has been removed anyway because it was a zombie " +
							"and not referenced within the profile.");
					}
				} else if (rebootRequired || rebootAttr == "true") {
					warning("Package processing (remove) failed for package " +
						packageName + ".\nHowever the package requires a reboot to complete. Rebooting.");
					// reboot system without adding to local settings yet
					reboot();
				} else if (rebootPostponed || rebootAttr == "postponed") {
					warning("Package processing (remove) failed for package " +
						packageName + ".\nHowever the package schedules a postponed reboot.");
				} else {
					// package installation failed
					success = false;
					message = "Could not process (remove) " + packageName + ".\n" +
								"Package still installed.";
					if (isQuitOnError()) {
						throw new Error(message);
					} else {
						error(message);
					}
				}
			}
		}
	}

	// return status
	return success;
}

/**
 * Removes a package by name.
 * @param name name of the package to be removed (package ID).
 * @return True in case of successful remove of package and all packages depending on it.
 *         False in case of failed package uninstall of failed uninstall of package depending on it.
 */
function removePackageName(name) {
	// Query the package node.
	var node = getSettingNode(name);

	// return code
	var success = false;
	
	dinfo("Removing package '" + name + "'.");
	
	if (node == null) {
		
		// check if the package has been removed during this session
		var alreadyRemoved = false;
		for (var iRemovedPkg = 0; iRemovedPkg < packagesRemoved.length; iRemovedPkg++) {
			var removedPackage = packagesRemoved[iRemovedPkg];
			if (name == getPackageID(removedPackage)) {
				alreadyRemoved = true;
				break;
			}
		}
		if (alreadyRemoved) {
			dinfo("Package '" + name + "' already removed during this session.");
			success = true;
		} else {
			info("Package '" + name + "' currently not installed.");
			success = false;
		}
	} else {
		success = removePackage(node);
	}
	return success;
}

/**
 * Removes all packages which depends on the given package.
 * Returns true in case all packages could be removed. Returns false if
 * at least one dependent package failed to remove.
 *
 * @param packageNode package to install the dependencies of (XML node)
 * 				NOTE: The package itself is not installed.
 * @return true=all dependencies installed successful;
 *         false=at least one dependency failed
 */
function removePackagesDependent(packageNode) {
	var packageID = getPackageID(packageNode);
	var packageName = getPackageName(packageNode);

	var problemDesc = "";
	// search for all packages which depend on the one to be removed
	var dependencies = new Array();
	var installedPackages = getSettingNodes();
	for (var iInstPkg = 0; iInstPkg<installedPackages.length; iInstPkg++) {
		// get dependencies of this package
		var pkgDeps = getPackageDependencies(installedPackages[iInstPkg]);
		for (var j=0; j<pkgDeps.length; j++) {
			if (pkgDeps[j] == packageID) {
				dependencies.push(installedPackages[iInstPkg]);
				break;
			}
		}
	}
	if (dependencies.length > 0) {
		info("Removing packages depending on '" + packageName +
			"' (" + packageID + ").");
	}
	var depSuccess = true;
	for (var iDependencies = 0; iDependencies < dependencies.length; iDependencies++) {
		var dependingPackage = dependencies[iDependencies];
		// install this package
		var success = removePackage(dependingPackage);
		if (!success) {
			problemDesc += "Removal of depending package '"
				+ getPackageName(dependingPackage) + "' ("
				+ getPackageID(dependingPackage) + ") failed";
			depSuccess = false;
			// skip remaining dependencies
			break;
		}
	}

	if (depSuccess) {
		dinfo("Removal of depending packages for '" +
				 packageName + "' (" +
				 packageID + ") successfully finished.");
	} else {
		var failMessage = "Removal of depending packages for '" +
						 packageName + "' (" +
						packageID + ") failed. " + problemDesc;
		if (isQuitOnError()) {
			throw new Error(failMessage);
		} else {
			error(failMessage);
		}
	}

	return depSuccess;
}

/**
 * Removes a package node from the setings XML node
 *
 * @return Returns true in case of success, returns false if no node could be removed
 */
function removeSetingsNode(packageNode) {
	return removeNode(getSettings(), packageNode);
}

/**
 * Sets new status of the case-sensitive flag
 *
 * @param newSensitivity true to enable case sensitivity,
 *			false to disable it (boolean)
 */
function setCaseSensitivity(newSensitivity) {
	caseSensitivity = newSensitivity;
}

/**
 * Sets debug value to the given state.
 *
 * @param newState new debug state
 */
function setDebug(newState) {
	debug = newState;
}

/**
 * Sets dry run value to the given state.
 *
 * @param newState new dry run state
 */
function setDryRun(newState) {
	dryrun = newState;
}

/**
 * Sets a new value for the forceinstall flag.
 *
 * @param newState new value for the forceinstall flag (boolean)
 */
function setForce(newState) {
	force = newState;
}

/**
 * Sets a new value for the forceinstall flag.
 *
 * @param newState new value for the forceinstall flag (boolean)
 */
function setForceInstall(newState) {
	forceInstall = newState;
}

/**
 * Set a new host name which will be used by the script. This is uesful for
 * debugging purposes.
 *
 * @param newHostname host name to be used
 */
function setHostname(newHostname) {
	hostname = newHostname;
}

/**
 * Sets a new profile-id attribute to the given host XML node
 *
 * @param hostNode the host XML node to modify
 * @param profileID the new profile ID to be written to this node
 */
function setHostProfile(hostNode, profileID) {
	hostNode.setAttribute("profile-id", profileID);
}

/**
 * Set a new hosts node
 *
 * @param newHosts the new hosts XML node to be used fro now on
 */
function setHosts(newHosts) {
	hosts = newHosts;
}

/**
 * Sets new value for the forcedremove flag.
 *
 * @param newState new value for the forcedremove flag (boolean).
 */
function setNoForcedRemove(newState) {
	noForcedRemove = newState;
}

/**
 * Sets new state for the noreboot flag.
 *
 * @param newState new state of the noreboot flag (boolean)
 */
function setNoReboot(newState) {
	noreboot = newState;
}

/**
 * Sets new state for the noremove flag.
 *
 * @param newState new state of the noremove flag (boolean)
 */
function setNoRemove(newState) {
	noRemove = newState;
}

/**
 * Sets new state for the noRunningState flag.
 *
 * @param newState new state of the noreboot flag (boolean)
 */
function setNoRunningState(newState) {
	noRunningState = newState;
}

/**
 * Sets a new package id-attribute to the given host XML node
 *
 * @param packageNode the package XML node to modify
 * @param packageID the new package ID to be written to this node
 */
function setPackageID(packageNode, packageID) {
	packageNode.setAttribute("id", packageID);
}

/**
 * Set a new packages node
 *
 * @param newPackages the new packages XML node to be used fro now on
 */
function setPackages(newPackages) {
	packages = newPackages;
	// iterate through all packages and set the package id to lower case
	// this allows XPath search for lowercase value later on (case-insensitive)
	if (packages != null && !isCaseSensitive()) {
		var packageNodes = getPackageNodes();
		for (var i=0; i<packageNodes.length; i++) {
			var packageNode = packageNodes[i];
			setPackageID(packageNode, getPackageID(packageNode).toLowerCase());
		}
	}
}

/**
 * Sets the status of postponed reboot. A postponed reboot schedules a system
 * reboot after finishing all actions (right before the script exits).
 *
 * @param newState new state of postponed reboot
 */
function setPostponedReboot(newState) {
	postponedReboot = newState;
}

/**
 * Sets a new profile id-attribute to the given profile XML node
 *
 * @param profileNode the profile XML node to modify
 * @param profileID the new profile ID to be written to this node
 */
function setProfileID(profileNode, profileID) {
	profileNode.setAttribute("id", profileID);
}

/**
 * Set a new profiles node
 *
 * @param newProfiles the new profiles XML node to be used fro now on
 */
function setProfiles(newProfiles) {
	profiles = newProfiles;
	// iterate through all profiles and set the profile id to lower case
	// this allows XPath search for lowercase value later on (case-insensitive)
	if (profiles != null && !isCaseSensitive()) {
		var profileNodes = getProfileNodes();
		for (var i=0; i<profileNodes.length; i++) {
			var profileNode = profileNodes[i];
			setProfileID(profileNode, getProfileID(profileNode).toLowerCase());
		}
	}
}

/**
 * Sets new state of the quiet flag
 *
 * @param newState new status of quiet flag (boolean)
 */
function setQuiet(newState) {
	quietMode = newState;
}

/**
 * Sets a new value for the quit on error flag.
 *
 * @param newState new value for the quit on error flag (boolean).
 */
function setQuitOnError(newState) {
	quitonerror = newState;
}

/**
 * Sets new value for the reboot command (rebootCmd).
 *
 * @param newCommand
 */
function setRebootCmd(newCommand) {
	rebootCmd = newCommand;
}

/**
 * Set state of application so other applications can see that it is running by
 * reading from the registry.
 *
 * @param statename String which is written to the registry as a value of the
 *                  "running" key
 */
function setRunningState(statename) {
	var WshShell = new ActiveXObject("WScript.Shell");
	var val;

	try {
		val = WshShell.RegWrite(sRegWPKG_Running, statename);
	} catch (e) {
		val = null;
	}

	return val;
}

/**
 * Sets new value for the sendStatus flag which defines if status messages
 * are sent to the calling program using STDOUT
 *
 * @param newStatus new value for the sendStatus flag (boolean)
 */
function setSendStatus(newStatus) {
	sendStatus = newStatus;
}

/**
 * Set a new settings node
 *
 * @param newSettings the new settings XML node to be used fro now on
 */
function setSettings(newSettings) {
	settings = newSettings;
	// iterate through all packages and set the package id to lower case
	// this allows XPath search for lowercase value later on (case-insensitive)
	if (settings != null && !isCaseSensitive()) {
		var packageNodes = getSettingNodes();
		for (var i=0; i<packageNodes.length; i++) {
			var packageNode = packageNodes[i];
			setPackageID(packageNode, getPackageID(packageNode).toLowerCase());
		}
	}
}

/**
 * Set new value for the boolean flag to disable/enable event log logging.
 * 
 * @param newValue value to be used for the skip event log flag from now on.
 */
function setSkipEventLog(newValue) {
	skipEventLog = newValue;
}

/**
 * Sorts package nodes by priority flag.
 *
 * @param packageNodes JScript Array containing package node entries
 * @param sortBy select the field to sort on. Supported Values are
 *               "PRIORITY" and "NAME"
 * @param sortOrder order in which the elements are sorted (integer)
 *                  valid values:
 *                  1 sort ascending (default)
 *                  2 sort descending
 *
 * @return new Array containing the same package nodes in sorted order (sorted by priority)
 */
function sortPackageNodes(packageNodes, sortBy, sortOrder) {
	// create array to do the sorting on
	var sortedPackages = new Array();
	for (var iPkgNodes = 0; iPkgNodes < packageNodes.length; iPkgNodes++) {
		sortedPackages.push(packageNodes[iPkgNodes]);
	}
	// Classic bubble-sort algorithm on selected attribute
	for (var iSortedPkg = 0; iSortedPkg < sortedPackages.length - 1; iSortedPkg++) {
		for (var j=0; j < sortedPackages.length - 1 - iSortedPkg; j++) {
			var prio1;
			var prio2;
			var priVal1 = null;
			var priVal2 = null;
			var pkg = sortedPackages[j];

			switch(sortBy) {
				case "NAME":
					priVal1 = getPackageName(sortedPackages[j]);
					priVal2 = getPackageName(sortedPackages[j + 1]);
					break;
				default:
					priVal1 = parseInt(getPackagePriority(sortedPackages[j]));
					priVal2 = parseInt(getPackagePriority(sortedPackages[j + 1]));
					break;
			}
			// If a priority is not set, we assume 0.

			if (priVal1 == null) {
				prio1 = 0;
			} else {
				prio1 = priVal1;
			}

			if (priVal2 == null) {
				prio2 = 0;
			} else {
				prio2 = priVal2;
			}

			var swapElements = false;
			switch (sortOrder) {
				case 2:
					if (prio1 < prio2) {
						swapElements = true;
					}
					break;
				default:
					if (prio1 > prio2) {
						swapElements = true;
					}
					break;
			}
			// If the priority of the first one in the list exceeds the second,
			// swap the packages.
			if (swapElements) {
				var tmp = sortedPackages[j];
				sortedPackages[j] = sortedPackages[j + 1];
				sortedPackages[j + 1] = tmp;
			}
		}
	}
	return sortedPackages;
}

/**
 * Sorts the settings file by package name.
 */
function sortSettings() {
	// sort current setting nodes
	var sortedPackages = sortPackageNodes(getSettingNodes(), "NAME", 1);

	// create new (empty) settings node
	var sortedSettings = createSettings();
	// use this settings node
	setSettings(sortedSettings);

	// fill new settings node with sorted packages (same order)
	for (var i=0; i<sortedPackages.length; i++) {
		addSettingsNode(sortedPackages[i]);
	}
}

/**
 * Synchronizes the current package state to that of the specified profile,
 * adding, removing or upgrading packages.
 */
function synchronizeProfile() {
	/**
	 * get package IDs of all packages which should be installed according to
	 * the profile. Regardless if the package exists within the package
	 * database.
	 */
	// var profilePackageIDs = getProfilePackageIDs();

	// send message to client
	logStatus("Starting software synchronization");

	/**
	 * Get package nodes referenced within the profile (and profile
	 * dependencies). This includes package dependencies as well.
	 */
	var profilePackageNodes = getProfilePackageNodes();
	dinfo("Synchronizing: Number of packages referenced by profile: " + profilePackageNodes.length);

	// get list of currently installed packages
	var installedPackages = getSettingNodes();

	// array to store packages to be removed
	var removablesArray = new Array();

	// Loop over each installed package and check whether it still applies.
	for (var iInstalledPkg = 0; iInstalledPkg < installedPackages.length; iInstalledPkg++) {
		var installedPackageNode = installedPackages[iInstalledPkg];
		dinfo("Found installed package '" + getPackageName(installedPackageNode) + "' (" +
				getPackageID(installedPackageNode) + ").");

		// Search for the installed package in available packages.
		var found = false;

		for (var j=0; j < profilePackageNodes.length; j++) {
			var profilePackageNode = profilePackageNodes[j];
			if (getPackageID(installedPackageNode) == getPackageID(profilePackageNode)) {
				dinfo("Package '" + getPackageName(installedPackageNode) + "' (" +
						getPackageID(installedPackageNode) + ") found in profile packages.");
				found = true;
				break;
			}
		}

		// If package is no longer present, mark for remove.
		if (!found) {
			dinfo("Marking package '" + getPackageName(installedPackageNode) + "' (" +
					getPackageID(installedPackageNode) + ") for remove");
			removablesArray.push(installedPackageNode);
		}
	}

	dinfo("Number of packages to remove: " + removablesArray.length);
	logStatus("Number of packages to be removed: " + removablesArray.length);
	/* upgrade packages to be removed to latest version first. This allows
	 * system administrators to provide a fixed version of the package which
	 * allows clean uninstall.
	 *
	 * This was done to allow fixing a broken uninstall-procedure
	 * on server side. Without upgrading to the latest version here it
	 * might happen that the package cannot be removed without the
	 * possibility to fix it. If you remove the package completely from
	 * the package database it will be forced to be removed from the local
	 * settings file even if uninstall fails.
	 *
	 * NOTE: This is not done within the same loop as the removal (see below)
	 * in order to prevent re-installing already removed dependencies.
	 */
	// sort packages to upgrade the ones with highest priority first
	if (isUpgradeBeforeRemove()) {
		var sortedUpgradeList = sortPackageNodes(removablesArray, "PRIORITY", 2);
		for (var iSortedPkg = 0; iSortedPkg < sortedUpgradeList.length; iSortedPkg++) {
			var upgradePkgNode = sortedUpgradeList[iSortedPkg];
			// upgrade package if package is available on server database
			var serverPackage = getPackageNode(getPackageID(upgradePkgNode));
			if (serverPackage != null) {
				logStatus("Remove: Checking status of '" + getPackageName(serverPackage) +
						"' (" + (iSortedPkg+1) + "/" + sortedUpgradeList.length + ")");
				// start upgrade first
				installPackage(serverPackage);
			}
		}
	}

	// Remove packages which do not exist in package database or do not apply
	// to the profile
	// reverse-sort packages to remove the one with lowest priority first
	var sortedRemovablesArray = sortPackageNodes(removablesArray, "PRIORITY", 1);
	for (var iRomovables = 0; iRomovables < sortedRemovablesArray.length; iRomovables++) {
		var removePkgNode = sortedRemovablesArray[iRomovables];
		// remove package from system
		// the settings node might have  been changed during update before
		// reload it.
		logStatus("Remove: Removing package '" + getPackageName(removePkgNode) +
				"' (" + (iRomovables+1) + "/" + sortedRemovablesArray.length + ")");
		// removePackage(getSettingNode(getPackageID(removePkgNode)));
		removePackageName(getPackageID(removePkgNode));
	}

	// create array to do the sorting on
	var sortedPackages = sortPackageNodes(profilePackageNodes, "PRIORITY", 2);

	/* Loop over each available package and install it. No check required if
	 * package is already installed or not. The install method will check by
	 * itself if the package needs to be installed/upgraded or no action is
	 * needed.
	 */
	for (var i=0; i < sortedPackages.length; i++) {
		// install/upgrade package
		logStatus("Install: Verifying package '" + getPackageName(sortedPackages[i]) +
				"' (" + (i+1) + "/" + sortedPackages.length + ")");
		installPackage(sortedPackages[i]);
	}

	logStatus("Finished software synchronization");

	// If we had previously warned the user about an impending installation, let
	// them know that all action is complete.
	notifyUserStop();
}

/* ****************************************************************************
 * XML handling
 * ****************************************************************************
 */

/**
 * Saves the root element to the specified XML file.
 */
function saveXml(root, path) {
	if (isDryRun()) {
		path += ".dryrun";
	}
	dinfo("Saving XML : " + path);
	var xmlDoc = new ActiveXObject("Msxml2.DOMDocument.3.0");
	xmlDoc.appendChild(root);
	if (xmlDoc.save(path)) {
		throw new Error(0, "Could not save XML document to " + path);
	}
}

/**
 * Creates a new root element of the specified name.
 */
function createXml(root) {
	var xmlDoc = new ActiveXObject("Msxml2.DOMDocument.3.0");

	return xmlDoc.createNode(1, root, "");
}

/**
 * Loads XML from the given path and/or directory.
 * Returns null in case XML could not be loaded.
 *
 * @param xmlPath optional path to XML file to be loaded, specify null if you
 *                do not want to load from XML file
 * @param xmlDirectory optional path to directory where XML file(s) might can
 *                     be found. Specify null if you do not want to read from a
 *                     directory.
 * @param rootNode The name of the root node to merge from the XML files.
 *                 e.g. specify "packages" to read all "<packages>" nodes.
 * @return XML root node containing all nodes from the specified files.
 */
function loadXml(xmlPath, xmlDirectory, rootNode) {
	// create variable to return
	var xmlRoot = null;
	var source = new ActiveXObject("Msxml2.DOMDocument.3.0");;

	if (xmlPath != null) {
		dinfo("Trying to read XML file: " + xmlPath);
		source.async = false;
		source.validateOnParse = false;
		source.load(xmlPath);

		// check if there was an error when loading XML
		if (source.parseError.errorCode != 0) {
			var loadError = source.parseError;
			var errorMessage = "Error parsing xml '" + xmlPath + "': " + loadError.reason + "\n" +
							"File      " + xmlPath + "\n" +
							"Line      " + loadError.line + "\n" +
							"Linepos   " + loadError.linepos + "\n" +
							"Filepos   " + loadError.filepos + "\n" +
							"srcText   " + loadError.srcText + "\n";
			if (isQuitOnError()) {
				throw new Error(errorMessage);
			} else {
				error(errorMessage);
			}
		} else {
			dinfo("Successfully loaded XML file: " + xmlPath);
			xmlRoot = source.documentElement;
		}
	}

	if (xmlDirectory != null) {
		dinfo("Trying to read XML files from directory: " + xmlDirectory);
		// check if directory exists
		var fso = new ActiveXObject("Scripting.FileSystemObject");
		if( fso.folderExists( xmlDirectory ) ) {
			var folder = fso.GetFolder(xmlDirectory);
			var e = new Enumerator(folder.files);
			var root = rootNode;
			if (root == null) {
				var folderName = folder.Name;
				// workaround since the root element of hosts.xml is not "hosts" but "wpkg"
				if( folderName == "hosts" ) {
					root = "wpkg";
				} else {
					root = folderName;
				}
			}

			// read all files
			for( e.moveFirst(); ! e.atEnd(); e.moveNext() ) {
				var file = e.item();
				var filePath = xmlDirectory.replace( /\\/g, "/" ) + "/" + file.name;

				// search for las ."
				var DotSpot = file.name.toString().lastIndexOf('.');
				var extension = file.name.toString().substr(DotSpot + 1, file.name.toString().length);

				// make sure to read only .xml files
				if(extension == "xml") {
					dinfo("Reading XML file: " + filePath);
					var str = "<?xml version=\"1.0\"?>\r\n";
					str += "<xsl:stylesheet xmlns:xsl=\"http://www.w3.org/1999/XSL/Transform\" version=\"1.0\">\r\n";
					str += "    <xsl:output encoding=\"ISO-8859-1\" indent=\"yes\" method=\"xml\" version=\"1.0\"/>\r\n";
					str += "    <xsl:template match=\"/\">\r\n";
					str += "        <" + root + ">\r\n";
					str += "            <xsl:copy-of select=\""+ root + "/child::*\"/>\r\n";
					str += "            <xsl:copy-of select=\"document('" +
											filePath +
											"')/" + root + "/child::*\"/>\r\n";
					str += "                </" + root + ">\r\n";
					str += "        </xsl:template>\r\n";
					str += "</xsl:stylesheet>\r\n";

					var xsl = new ActiveXObject( "Msxml2.DOMDocument.3.0" );
					xsl.async = false;
					xsl.loadXML( str );

					// check if load was successful
					if (xsl.parseError.errorCode != 0) {
						var loadErr = xsl.parseError;
						var errMsg = "Error parsing xml '" + filePath + "': " + loadErr.reason + "\n" +
										"File      " + file.name + "\n" +
										"Line      " + loadErr.line + "\n" +
										"Linepos   " + loadErr.linepos + "\n" +
										"Filepos   " + loadErr.filepos + "\n" +
										"srcText   " + loadErr.srcText + "\n";
						if (isQuitOnError()) {
							throw new Error(errMsg);
						} else {
							error(errMsg);
						}
					} else {
						// try to add to root element
						try {
							if (xmlRoot == null) {
								xmlRoot = source.loadXML( source.transformNode( xsl ) ).documentElemet;
							} else {
								source.loadXML( source.transformNode( xsl ) );
								xmlRoot = source.documentElement;
							}
						} catch (err) {
							if (isQuitOnError()) {
								throw new Error("Error reading file: " + filePath + "\n\n" +
												 err.description);
							} else {
								error("Error reading file: " + filePath + "\n" + err.description);
							}
						}
					}
				}
			}
		} else {
			dinfo("Specified XML directory does not exist: " + xmlDirectory);
		}
	}
	return xmlRoot;
}

/**
 * Removes a sub-node from the given XML node entry.
 *
 * @param XMLNode the XML node to remove from (e.g. packges or settings)
 * @param subNode the node to be removed from the XMLNode (for example a package node)
 * @return Returns true in case of success, returns false if no node could be removed
 */
function removeNode(XMLNode, subNode) {
	var returnvalue = false;
	var result = XMLNode.removeChild(subNode);
	if(result != null) {
		returnvalue = true;
	}
	return returnvalue;
}

/**
 * Returns a new array of XML nodes unique by the specified attribute.
 */
function uniqueAttributeNodes(nodes, attribute) {
	// Hold unique nodes in a new array.
	var newNodes = new Array();

	// Loop over nodes provided nodes searching for duplicated entries.
	for (var i = 0; i < nodes.length; i++) {
		// Get node for this loop.
		var node = nodes[i];

		// Get attribute which should be unique
		var attributeValue = node.getAttribute(attribute);

		// Determine if node with attribute already exists.
		var found = false;

		// Loop over elements of new nodes array and look for pre-existing element.
		for (var j = 0; j < newNodes.length; j++) {
			var newNodeAttribute = newNodes[j].getAttribute(attribute);
			if (attributeValue == newNodeAttribute) {
				found = true;
				break;
			}
		}

		// If it doesn't exist, add it.
		if (!found) {
			newNodes.push(node);
		}
	}
	return newNodes;
}

/* ****************************************************************************
 * Initialization and cleanup
 * ****************************************************************************
 */

/**
 * Clean up function called at the end. Writes all required files, closes
 * handlers and prints/writes log. Then exits with the given exit code.
 */
function cleanup() {
	// write settings XML file
	saveSettings();

	// close log file
	// do not close  the file if reboot is in progress
	// this is done since there might still be some writes to the file
	// before the reboot actually takes place
	if (getLogLevel() > 0 && !rebooting && logfileHandler != null) {
		// close the log
		getLogFile().Close();
	}
}

/**
 * Ends program execution with the specified exit code.
 */
function exit(exitCode) {
	// print packages which have not been removed
	var skippedPackages = getSkippedRemoveNodes();
	if (skippedPackages.length > 0) {
		var message = "Packages where removal has been aborted:\n";
		for (var i=0; i<skippedPackages.length; i++) {
			var packageNode = skippedPackages[i];
			message += getPackageName(packageNode) + " (" +
					getPackageID(packageNode) + ")\n";
		}
		info(message);
	}

	// check if there is a postponed reboot scheduled
	// cleanup is done directly within the reboot function
	if (isPostponedReboot()) {
		// postponed reboot executed
		setPostponedReboot(false);
		reboot();
	}

	// run cleanup
	cleanup();

	// reset running state
	if (!isNoRunningState()) {
		// Reset running state.
		setRunningState("false");
	}

	WScript.Quit(exitCode);
}

/**
 * Initializes the system, all required variables...
 */
function initialize() {
	// get argument list
	var argv = getArgv();
	// Get special purpose argument lists.
	var argn = argv.Named;

	// will be used for file operations
	var fso = new ActiveXObject("Scripting.FileSystemObject");

	var httpregex = new RegExp("^http");

	var isWeb = false;
	var base = "";

	if (argn("base") != null) {
		base = argn("base");
		if(httpregex.test(base)) {
			isWeb = true;
		} else {
			isWeb = false;
			base = fso.GetAbsolutePathName(base);
		}
	} else {
		if(httpregex.test(wpkg_base)) {
			isWeb = true;
			base = wpkg_base;
		} else {
			// Use the executing location of the script as the default base path.
			isWeb = false;
			var path = WScript.ScriptFullName;
			base = fso.GetParentFolderName(path);
		}
	}
	dinfo("Base directory is '" + base + "'.");
	dinfo("Log level is " + getLogLevel());

	var packages_file;
	var profiles_file;
	var hosts_file;
	var nodes;
	if (!isWeb) {
		// Append the settings file names to the end of the base path.
		packages_file = fso.BuildPath(base, packages_file_name);
		var packages_folder = fso.BuildPath(base, "packages");
		profiles_file = fso.BuildPath(base, profiles_file_name);
		var profiles_folder = fso.BuildPath(base, "profiles");
		hosts_file = fso.BuildPath(base, hosts_file_name);
		var hosts_folder = fso.BuildPath(base, "hosts");
		nodes = loadXml(profiles_file, profiles_folder, "profiles");
		if (nodes == null) {
			// connot continue without profiles (probably network error occurred)
			throw new Error(10, "No profiles found. Aborting");
		}
		setProfiles(nodes);
		nodes = loadXml(hosts_file, hosts_folder, "wpkg");
		if (nodes == null) {
			// connot continue without hosts (probably network error occurred)
			throw new Error(10, "No hosts found. Aborting");
		}
		setHosts(nodes);
		// load packages
		setPackages(loadXml(packages_file, packages_folder, "packages"));
	} else {
		packages_file = base + "/" + web_packages_file_name;
		profiles_file = base + "/" + web_profiles_file_name;
		hosts_file = base + "/" + web_hosts_file_name;
		nodes = loadXml( profiles_file, null, null );
		if (nodes == null) {
			// connot continue without profiles (probably network error occurred)
			throw new Error(10, "No profiles found. Aborting");
		}
		setProfiles(nodes);
		nodes = loadXml( hosts_file, null, null );
		if (nodes == null) {
			// connot continue without hosts (probably network error occurred)
			throw new Error(10, "No hosts found. Aborting");
		}
		setHosts(nodes);
		// load packages
		setPackages(loadXml( packages_file , null, null));
	}
	// set profile-based log level (if available)
	var profileLogLevel = getProfilesLogLevel();
	if (profileLogLevel != null) {
		setLogLevel(profileLogLevel);
	}
	// now all parameters are set to build the final log file name
	// even if [PROFILE] is used
	if (logfileHandler != null) {
		// only needs to be re-initialized if it has not yet been opened
		initializeLog();
	}

	// our settings file is located in System32
	var SystemFolder = 1;
	var settings_folder = null;
	if (settings_file_path != null) {
		settings_file = new ActiveXObject("WScript.Shell").ExpandEnvironmentStrings(settings_file_path + "\\" + settings_file_name);
	} else {
		settings_folder = fso.GetSpecialFolder(SystemFolder);
		settings_file = fso.BuildPath(settings_folder, settings_file_name);
	}

	// Load packages and profiles.
	if (isForce() && isArgSet(argv, "/synchronize")) {
		dinfo("Skipping current settings. Checking for actually installed packages.");

		setSettings(createSettings());

		fillSettingsWithInstalled();

	} else {
		// Load or create settings file.
		if (!fso.fileExists(settings_file)) {
			dinfo("Settings file does not exist. Creating a new file.");

			setSettings(createSettings());
		} else {
			dinfo("Reading settings file: " + settings_file);
			setSettings(createSettingsFromFile(settings_file));
		}
	}

	var message;
	if(isDebug()) {
		var hst = getHostNodes();
		message = "Hosts file contains " + hst.length + " hosts:";
		for (var iHost = 0; iHost < hst.length; iHost++ ) {
			message += "\n" + getHostNameAttribute(hst[iHost]);
		}
		dinfo(message);

		var settingsPkg = getSettingNodes();
		message = "Settings file contains " + settingsPkg.length + " packages:";
		for (var iSettings = 0; iSettings < settingsPkg.length; iSettings++) {
			if (settingsPkg[iSettings] != null) {
				 message += "\n" + getPackageID(settingsPkg[iSettings]);
			}
		}
		dinfo(message);

		var packageNodes = getPackageNodes();
		message = "Packages file contains " + packageNodes.length + " packages:";
		for (var iPackage = 0; iPackage < packageNodes.length; iPackage++) {
			if (packageNodes[iPackage] != null) {
				 message += "\n" + getPackageID(packageNodes[iPackage]);
			}
		}
		dinfo(message);

		var profileNodes = getProfileNodes();
		message = "Profile file contains " + profileNodes.length + " profiles:";
		for (var iProfile = 0; iProfile < profileNodes.length; iProfile++) {
			if (profileNodes[iProfile] != null) {
				 message += "\n" + getProfileID(profileNodes[iProfile]);
			}
		}
		dinfo(message);

		// get profile list
		var profiles = getProfileList();
		message = "Using profile(s):\n";
		for (var i=0; i<profiles.length; i++) {
			message += profiles[i] + "\n";
		}
		dinfo(message);
	}

	// check if all referenced profiles are available
	var profileList = getProfileList();
	var error = false;
	message = "Could not locate referenced profile(s):\n";
	for (var iProf = 0; iProf<profileList.length; iProf++) {
		var currentProfile = getProfileNode(profileList[iProf]);
		if (currentProfile == null) {

			error = true;
			message += profileList[iProf] + "\n";
		}
	}
	if (error) {
		throw new Error(message);
	}
}

/**
 * Initializes configuration file
 */
function initializeConfig() {
	// get list of parameters (<param... /> nodes)
	var param = getConfigParamArray();

	// loop through all parameters
	for (var i=0; i < param.length; i++) {
		var name = param[i].getAttribute("name");
		var value= param[i].getAttribute("value");
		if (name == "volatileReleaseMarker") {
			volatileReleaseMarkers.push((param[i].getAttribute("value")).toLowerCase());
		} else if(value === "true" || value === "false" || value === "null") {
			// If value is boolean or null, we don't want " around it.
			// Otherwise it'll be assigned as a string.

			// Here is where the <param name='...' ... /> is used as the variable name and assigned the
			// <param ... value='...' /> value from the config.xml file.  We're using eval to do variable
			// substitution for the variable name.
			eval ( name + " = " + value );
		} else {
			// Non-Boolean value, put " around it.

			// Here is where the <param name='...' ... /> is used as the variable name and assigned the
			// <param ... value='...' /> value from the config.xml file.  We're using eval to do variable
			// substitution for the variable name.
			eval ( name + " = \"" + value + "\"" );
		}
	}
}

/**
 * Initializes log file depending on information available.
 * If log file path is not set or unavailable creates logfile within %TEMP%.
 * Sets log file handler to null in case logging is disabled (logLevel=0)
 */
function initializeLog() {
	// only initialize a log file if log level is greater than 0
	if (getLogLevel() > 0) {
		/** stores the existing filehandler at method entry */
		var oldLogfileHandler = logfileHandler;
		var oldLogfilePath = logfilePath;

		/** stores the new filehandler created during this execution */
		var newLogfileHandler = null;

		/** file system object */
		var fso = new ActiveXObject("Scripting.FileSystemObject");

		// gracefully close current log if available
		/** this is a work-around to prevent infinite loops which can occur in
		 * case logging is issued from any functions within the initialization
		 * below. All logs issued before the final target log file is initialized
		 * are written to this temporary file.
		 */
		// initialize temporary local log file to allow logging as quick as possible
		if (oldLogfileHandler == null) {
			var tempLogPath = new ActiveXObject("WScript.Shell").ExpandEnvironmentStrings("%TEMP%\\wpkg-logInit.log");
			// create new temporary file - overwrite existing
			oldLogfileHandler = fso.OpenTextFile(tempLogPath, 2, true, -2);
			// make sure all following messages are logged to this file
			logfileHandler = oldLogfileHandler;
			logfilePath = tempLogPath;
			dinfo("Initialized temporary local log file: " + logfilePath);
		}

		// try to initialize real log file
		var logPath = null;

		try {
			// build log file name
			var today = new Date();
			var year = today.getFullYear();
			var month = today.getMonth() + 1;
			var day = today.getDate();
			var hour = today.getHours();
			var minute = today.getMinutes();
			var second = today.getSeconds();
			if (month < 10) {
				month = "0" + month;
			}
			if (day < 10) {
				day = "0" + day;
			}
			if (hour < 10) {
				hour = "0" + hour;
			}
			if (minute < 10) {
				minute = "0" + minute;
			}
			if (second < 10) {
				second = "0" + second;
			}

			var logFileName = logfilePattern.replace(new RegExp("\\[HOSTNAME\\]", "g"), getHostname());
			logFileName = logFileName.replace(new RegExp("\\[YYYY\\]", "g"), year);
			logFileName = logFileName.replace(new RegExp("\\[MM\\]", "g"), month);
			logFileName = logFileName.replace(new RegExp("\\[DD\\]", "g"), day);
			logFileName = logFileName.replace(new RegExp("\\[hh\\]", "g"), hour);
			logFileName = logFileName.replace(new RegExp("\\[mm\\]", "g"), minute);
			logFileName = logFileName.replace(new RegExp("\\[ss\\]", "g"), second);
			// only apply profile if required
			/* NOTE: In case profiles.xml is not valid this will quit the script on
			 * getProfile() call while keeping the temporary local log file handler.
			 * As a result errors at initialization will be logged to local log only.
			 * So make sure not to use the [PROFILE] placeholder if you like to remote-
			 *  initialization logs (e.g. missing XML files).
			 */
			var regularExp = new RegExp("\\[PROFILE\\]", "g");
			if (regularExp.test(logFileName)) {
				// this will throw an error if profile is not available yet
				var profileList = getProfileList();
				// concatenate profile names or throw error if no names available
				if (profileList.length > 0) {
					var allProfiles = "";
					for (var i=0; i<profileList.length; i++) {
						if (allProfiles == "") {
							allProfiles = profileList[i];
						} else {
							allProfiles += "-" + profileList[i];
						}
					}
					logFileName = logFileName.replace(regularExp, allProfiles);
				} else {
					throw new Error("Profile information not available.");
				}
			}

			if (log_file_path == null || log_file_path == "") {
				log_file_path = "%TEMP%";
			}

			newLogfilePath = new ActiveXObject("WScript.Shell").ExpandEnvironmentStrings(log_file_path + "\\" + logFileName);

			// just open the log file in case it is not opened already
			if (logfilePath != newLogfilePath) {
				// 2=write (use 8 for append mode)
				// true=create if not exist
				// 0=ASCII, -1=unicode, -2=system default
				dinfo("Initializing new log file: " + newLogfilePath);
				try {
					var openMode = 2;
					if (isLogAppend()) {
						openMode = 8;
					}
					newLogfileHandler = fso.OpenTextFile(newLogfilePath, openMode, true, -2);
				} catch (e) {
					// fall back to local temp folder
					newLogfilePath = new ActiveXObject("WScript.Shell").ExpandEnvironmentStrings("%TEMP%\\" + logFileName);
					dinfo("Failed to open log file: " + e.description + "; falling back to local logging: " + logPath);
					if (logfilePath != newLogfilePath) {
						newLogfileHandler = fso.OpenTextFile(newLogfilePath, 2, true, -2);
					}
				}
			}
		} catch (err) {
			dinfo("Cannot initialize log file, probably not all data available " +
					"yet, stick with local log file: " + logfilePath);
		}
		if (newLogfileHandler != null) {
			logfileHandler = newLogfileHandler;
			oldLogfilePath = logfilePath;
			logfilePath = newLogfilePath;
			if (oldLogfileHandler != null) {
				// transfer all logs to the new logfile and close old log file
				oldLogfileHandler.Close();
			}
			if (oldLogfilePath != null) {
				// open read-only
				var readerFile = fso.OpenTextFile(oldLogfilePath, 1, true, -2);
				while (!readerFile.AtEndOfStream) {
					logfileHandler.WriteLine(readerFile.ReadLine());
				}
				readerFile.Close();
				// delete old logfile
				fso.DeleteFile(oldLogfilePath, true);
			}
		}
	} else {
		// no log file is to be used
		logfileHandler = null;
		logfilePath = null;
	}
}

/**
 * Processes command line options and sets internal variables accordingly.
 */
function parseArguments(argv) {
	// Initialize temporary log file
	// Note: this will be done automatically on first log output
	// initializeLog();

	// Get special purpose argument lists.
	var argn = argv.Named;
	var argu = argv.Unnamed;

	// Process property named arguments that set values.
	if (isArgSet(argv, "/quiet")) {
		setQuiet(true);

	// check quiet value which was probably set within config.xml
	} else if (quiet != null) {
		setQuiet(quiet);
	} else {
		setQuiet(quietDefault);
	}

	// process log append flag
	if (isArgSet(argv, "/logAppend")) {
		setLogAppend(true);
	}

	// Process log level
	if (argn("logLevel") != null) {
		setLogLevel(parseInt(argn("logLevel")));
	} else if (logLevel != null) {
		setLogLevel(logLevel);
	} else {
		setLogLevel(logLevelDefault);
	}

	// IMPORTANT: THIS NEEDS TO BE DONE BEFORE FIRST LOG OUTPUT IS WRITTEN
	// IN ORDER TO ALLOW COORECT HOSTNAME REPLACEMENT IN LOGFILE PATTERN!
	// Set the profile from either the command line or the hosts file.
	if (argn("host") != null) {
		setHostname(argn("host"));
	}

	// Process log file pattern
	if (argn("logfilePattern") != null) {
		logfilePattern = argn("logfilePattern");
	}

	// Process path to log file
	if (argn("log_file_path") != null) {
		log_file_path = argn("log_file_path");
	}

	// Process property named arguments that set values.
	if (isArgSet(argv, "/dryrun")) {
		setDryRun(true);
		setDebug(true);
		setNoReboot(true);
	}

	// Process property named arguments that set values.
	if (isArgSet(argv, "/debug") || isArgSet(argv, "/verbose")) {
		setDebug(true);
	}

	// If the user is wanting command help, give it to him.
	if (isArgSet(argv, "/help")) {
		showUsage();
		exit(0);
	}

	// If the user passes /nonotify, we don't want to notify the user.
	if (isArgSet(argv, "/nonotify")) {
		setNoNotify(true);
	}

	// If the user passes /noreboot, we don't want to reboot.
	if (isArgSet(argv, "/noreboot")) {
		setNoReboot(true);
	}

	// do not remove packages if the user specified /noremove
	if (isArgSet(argv, "/noremove")) {
		setNoRemove(true);
	}

	// Process property named arguments that set values.
	if (isArgSet(argv, "/force")) {
		setForce(true);
	}

	// Process property named arguments that set values.
	if (isArgSet(argv, "/quitonerror")) {
		setQuitOnError(true);
	}

	// check if status messages should be sent
	if (isArgSet(argv, "/sendStatus")) {
		setSendStatus(true);
	}

	// check if upgrade-before-remove feature should be enabled
	if (isArgSet(argv, "/noUpgradeBeforeRemove")) {
		setUpgradeBeforeRemove(false);
	}

	// Process property named arguments that set values.
	if (isArgSet(argv, "/forceinstall")) {
		setForceInstall(true);
	}

	if (isArgSet(argv, "/noforcedremove")) {
		setNoForcedRemove(true);
	}

	if (argn("rebootcmd") != null) {
		setRebootCmd(argn("rebootcmd"));
	}
	dinfo("Reboot-Cmd is " + getRebootCmd() + ".");

	// Want to export the state of WPKG to registry?
	if (isArgSet(argv, "/norunningstate")) {
		setNoRunningState(true);
	} else {
		// Indicate that we are running.
		setNoRunningState(false);
	}

	// do we want case insensitivity?
	if (isArgSet(argv, "/ignoreCase")) {
		setCaseSensitivity(false);
	}
}

/**
 * saves settings to file system
 */
function saveSettings() {
	dinfo("Saving sorted settings to '" + settings_file + "'.");
	sortSettings();
	if (settings_file != null && getSettings() != null) {
		saveXml(getSettings(), settings_file);
	} else {
		dinfo("Settings not saved!");
	}
}

/* ****************************************************************************
 * LOG FUNCTIONS
 * ****************************************************************************
 */

/**
 * Echos text to the command line or a prompt depending on how the program is
 * run.
 */
function alert(message) {
	WScript.Echo(message);
}

/**
 * Presents some debug output if debugging is enabled
 */
function dinfo(stringInfo) {
	log(8, stringInfo);
}

/**
 * Logs or presents an error message depending on interactivity.
 */
function error(message) {
	log(1, message);
}

/**
 * Returns log file handler. If logfile has not been initialized yet, starts
 * initialization and returns new filehandler.
 *
 * Returns null in case logLevel is set to 0.
 *
 * @return log file handler (returns null if log level is 0)
 */
function getLogFile() {
	if (logfileHandler == null) {
		initializeLog();
	}
	return logfileHandler;
}

/**
 * Creates a log line from a given string. The severity string is automatically
 * padded to a fixed length too to make the log entries easily readable.
 *
 * @param severity string which represents log severity
 * @param message string which represents the message to be logged
 * @return log entry in its default format:
 * 			YYYY-MM-DD hh:mm:ss, SEVERITY: <message>
 */
function getLogLine(severity, message) {
	var severityPadding = 7;
	// pad string with spaces
	for (var i = severity.length; i <= severityPadding; i++) {
		severity += " ";
	}

	// escape pipes (since they are used as new-line characters)
	var logLine = message.replace(new RegExp("\\|", "g"), "\\|");
	// replace new-lines by pipes
	logLine = logLine.replace(new RegExp("(\\r\\n)|(\\n\\r)|[\\r\\n]+", "g"), "|");

	// build date string
	var today = new Date();
	var year = today.getFullYear();
	var month = today.getMonth() + 1;
	var day = today.getDate();
	var hour = today.getHours();
	var minute = today.getMinutes();
	var second = today.getSeconds();
	if (month < 10) {
		month = "0" + month;
	}
	if (day < 10) {
		day = "0" + day;
	}
	if (hour < 10) {
		hour = "0" + hour;
	}
	if (minute < 10) {
		minute = "0" + minute;
	}
	if (second < 10) {
		second = "0" + second;
	}

	var tstamp = year + "-" + month + "-" + day + " " + hour + ":" + minute + ":" + second;

	// build log line
	logLine = tstamp + ", " + severity + ": " + logLine;

	return logLine;
}

/**
 * Returns the current log level:
 *
 * @return Log level
 * 0: do not log anything, disables writing of a log-file
 * 1: log errors only
 * 2: log errors and warnings
 * 4: log errors, warnings and information
 */
function getLogLevel() {
	return logLevelValue;
}

/**
 * Logs or presents an info message depending on interactivity.
 */
function info(message) {
	log(4, message);
}

/**
 * Logs the specified event type and description in the Windows event log.
 * Log types:
 * 0    SUCCESS
 * 1    ERROR
 * 2    WARNING
 * 4    INFORMATION
 * 8    AUDIT_SUCCESS
 * 16   AUDIT_FAILURE
 */
function log(type, description) {
	// just log information level to event log or everything in case debug is
	// enabled.
	if ((type & 7) > 0 || isDebug()) {
		if(isQuiet() && !isSkipEventLog()) {
			try {
				WshShell = WScript.CreateObject("WScript.Shell");
				WshShell.logEvent(type, "" + description);
			} catch (e) {
				// skip future event log entries and log an error
				setSkipEventLog(true);
				var message = "Error when writing to event log, falling back" +
							" to standard output (STDOUT).\n" +
							"Description: " + e.description + "\n" +
							"Error number: " + hex(e.number) + "\n" +
							"Stack: " + e.stack  + "\n" +
							"Line: " + e.lineNumber + "\n";
				error(message);

				// write message to STDOUT to ensure it is not lost
				alert(description);
			}
		} else {
			alert(description);
		}
	}
	if ((type & getLogLevel()) > 0) {
		// write to log file
		var logSeverity = "unspecified";
		switch(type) {
			case 0:
				logSeverity = "SUCCESS";
				break;
			case 1:
				logSeverity = "ERROR";
				break;
			case 2:
				logSeverity = "WARNING";
				break;
			case 4:
				logSeverity = "INFO";
				break;
			case 8:
				logSeverity = "DEBUG";
				break;
			case 16:
				logSeverity = "DEBUG";
				break;
		}

		getLogFile().WriteLine(getLogLine(logSeverity, description));
	}
}

/**
 * Logs status message which can be read by WPKG client to display messages
 * to the user
 *
 * @param message the message to be sent to the client.
 */
function logStatus(message) {
	if (isSendStatus()) {
		alert(getLogLine("STATUS", message));
	}
}

/**
 * Notifies the user/computer with a pop up message.
 */
function notify(message) {
	if (!isNoNotify()) {
		var cmd = "";
		cmd += "%SystemRoot%\\System32\\NET.EXE SEND ";
		cmd += getHostname();
		cmd += " \"" + message + "\"";
		try {
			exec(cmd, 0, null);
		} catch (e) {
			var errorMessage = "Notification failed. " + e.description;
			if (isQuitOnError()) {
				throw new Error(0, errorMessage);
			} else {
				error(errorMessage);
			}
		}
	} else {
		info("User notification suppressed. Message: " + message);
	}
}

/**
 * Sends a message to the system console notifying the user that installation
 * failed.
 */
function notifyUserFail() {
	// get localized message
	var msg = getLocalizedString("notifyUserFail");
	if (msg == null) {
		msg = "The software installation has failed.";
	}

	try {
		notify(msg);
	} catch (e) {
		error("Unable to notify the user that all action has been completed.");
	}
}

/**
 * Sends a message to the system console notifying of impending action.
 */
function notifyUserStart() {
	if (!was_notified) {
		// get localized message
		var msg = getLocalizedString("notifyUserStart");
		if (msg == null) {
			msg = "";
			msg += "The automated software installation utility has or is ";
			msg += "currently applying software updates to your system. Please ";
			msg += "check the time shown at the beginning of this message to ";
			msg += "determine if it is out of date. If not, please save all your ";
			msg += "open documents, as the system might require a reboot. If so, ";
			msg += "the system will be rebooted with no warning when installation ";
			msg += "is complete. Thank you.";
		}

		was_notified = true;

		try {
			notify(msg);
		} catch (e) {
			throw new Error(0, "Unable to notify user that the system was " +
				"about to begin updating. " + e.description);
		}
	}
}

/**
 * Sends a message to the system console notifying them that all action is
 * complete.
 */
function notifyUserStop() {
	if(was_notified) {
		// get localized message
		var msg = getLocalizedString("notifyUserStop");
		if (msg == null) {
			msg = "";
			msg += "The automated software installation utility has completing ";
			msg += "installing or updating software on your system. No reboot was ";
			msg += "necessary. All updates are complete.";
		}

		try {
			notify(msg);
		} catch (e) {
			error("Unable to notify the user that all action has been completed.");
		}
	}
}

/**
 * Sets new log append value.
 *
 * @param append true if log should be appended, false otherwise (boolean)
 */
function setLogAppend(append) {
	logAppend = append;
}

/**
 * Sets new logging level.
 *
 * @param newLevel new log level to be used:
 * 0: do not log anything, disables writing of a log-file
 * 1: log errors only
 * 2: log errors and warnings
 * 4: log errors, warnings and information
 */
function setLogLevel(newLevel) {
	logLevelValue = parseInt(newLevel);
}

/**
 * Sets new state for the nonotify flag.
 *
 * @param newState new state of the nonotify flag (boolean)
 */
function setNoNotify(newState) {
	nonotify = newState;
}

/**
 * Sets new state for the upgrade-before-remove flag.
 * 
 * @param newState set to true if you want to enable the
 *                 upgraede-before-remove feature. Otherwise set false.
 */
function setUpgradeBeforeRemove(newState) {
	noUpgradeBeforeRemove = !newState;
}

/**
 * Logs or presents a warning message depending on interactivity.
 */
function warning(message) {
	log(2, message);
}

/* ****************************************************************************
 * SUPPLEMENTARY FUNCTIONS
 * Not directly related to the application logic but used by several functions
 * to fulfill the task.
 * ****************************************************************************
 */


/**
 * Combines one list and another list into a single array.
 */
function concatenateList(list1, list2) {
	// Create a new array the size of the sum of both original lists.
	var list = new Array();

	for (var iList1 = 0; iList1 < list1.length; iList1++) {
		list.push(list1[iList1]);
	}

	for (var iList2 = 0; iList2 < list2.length; iList2++) {
		list.push(list2[iList2]);
	}

	return list;
}


/**
 * Downloads a file by url, target directory and timeout
 *
 * @param url full file URL to download (http://www.server.tld/path/file.msi)
 * @param target target directory do download to. This is specified relative
 *               to the downloadUrl path as specified within config.xml
 * @param timeoutValue timeout in seconds
 * @return true in case of successful download, false in case of error
 */
function downloadFile(url, target, timeoutValue) {
	if (url == null || url == "") {
		error("No URL specified for download!");
		return false;
	}
	try {
		// evaluate target directory
		if (target == null || target == "") {
			error("Invalid download target specified: " + target);
			return false;
		} else {
			target = downloadDir + "\\" + target;
		}
		target = new ActiveXObject("WScript.Shell").ExpandEnvironmentStrings(target);

		// evaluate timeout
		var timeout = downloadTimeout;
		if (timeoutValue != null && timeoutValue == "") {
			timeout = parseInt(timeoutValue);
		}
		var fso = new ActiveXObject("Scripting.FileSystemObject");
		var stream = new ActiveXObject("ADODB.Stream");
		var xmlHttp = new createXmlHttp();

		dinfo("Downloading '" + url + "' to '" + target + "'");

		// open HTTP connection
		xmlHttp.open("GET", url, true);
		xmlHttp.setRequestHeader("User-Agent", "XMLHTTP/1.0");
		xmlHttp.send();

		for (var t=0; t < timeout; t++) {
			if (xmlHttp.ReadyState == 4) {
				break;
			}
			WScript.sleep(1000);
		}

		// abort download if not finished yet
		if (xmlHttp.ReadyState != 4) {
			xmlHttp.abort();
			error("HTTP Timeout after " + timeout + " seconds.");
		}

		// check if download has been completed
		if (xmlHttp.status != 200) {
			error("HTTP Error: " + xmlHttp.status + ", " + xmlHttp.StatusText);
		}

		stream.open();
		stream.type = 1;

		stream.write(xmlHttp.responseBody);
		stream.position = 0;

		// delete temporary file if it already exists
		if (fso.fileExists(target)) {
			fso.deleteFile(target);
		}

		// check if target folder exists, crate if required
		var folder = fso.getParentFolderName(target);
		var folderStructure = new Array();

		while (!fso.FolderExists(folder)) {
			folderStructure.push(folder);
			folder = fso.getParentFolderName(folder);
		}
		// create folders
		for (var i=folderStructure.length-1; i>=0; i--) {
			fso.createFolder(folderStructure[i]);
		}

		// write file
		stream.saveToFile(target);
		stream.close();

	} catch (e) {
		error("Download failed: " + e.description);
		return false;
	}

	return true;
}

/**
 * This method is used to return an XMLHTTP object. Depending on the MSXML
 * version used the factory is different.
 * 
 * @return XMLHTTP object
 */
function createXmlHttp() {
	var xmlHttpFactories = [
		function () {return new XMLHttpRequest();},
		function () {return new ActiveXObject("Msxml2.XMLHTTP");},
		function () {return new ActiveXObject("Msxml3.XMLHTTP");},
		function () {return new ActiveXObject("Microsoft.XMLHTTP");}
	];

	var xmlHttp = null;
	for (var i=0; i < xmlHttpFactories.length; i++) {
		try {
			xmlHttp = xmlHttpFactories[i]();
		} catch (e) {
			continue;
		}
		break;
	}
	return xmlHttp;
}



/**
 * Executes a shell command and blocks until it is completed, returns the
 * program's exit code. Command times out and is terminated after the
 * specified number of seconds.
 *
 * @param cmd the command line to be executed
 * @param timeout timeout value in seconds (use value <= 0 for default timeout)
 * @param workdir working directory (optional). If set to null uses the current
 *                working directory of the script.
 * @return command exit code (or -1 in case of timeout)
 */
function exec(cmd, timeout, workdir) {
	if (isDryRun()) {
		return 0;
	}

	try {
		var shell = new ActiveXObject("WScript.Shell");

		// Timeout after an hour by default.
		if (timeout <= 0) {
			timeout = 3600;
		}

		// set working directory (if supplied)
		if (workdir != null && workdir != "") {
			workdir = shell.ExpandEnvironmentStrings(workdir);
			dinfo("Switching to working directory: " + workdir);
			shell.CurrentDirectory = workdir;
		}

		dinfo("Executing command: " + cmd);
		var shellExec = shell.exec(cmd);

		var count = 0;
		while (shellExec.status == 0) {
			WScript.sleep(1000);
			count++;

			/*
			 * Unfortunately WSH is terribly broken when handling I/O streams
			 * from processes. AtEndOfStream blocks as well as ReadAll(),
			 * Read(x) and ReadLine(). So it's impossible to fetch STDOUT/
			 * STDERR without blocking the main WPKG program.
			 * So either you can fetch the output or wait for the program to
			 * terminate, but not both.
			 * For WPKG it's more important to handle a timeout in order to
			 * handle programs which do not terminate properly or interactively
			 * ask for input.
			 * Unfortunately sub-processes seem to be blocked if they write
			 * more than 4k of data to STDOUT and/or STDERR buffer. So make
			 * sure your commands do not print too much on the console.
			 * If in doubt you might redirect STDOUT/STDERR to a file.
			 * For example by adding "> %TEMP%\myprog-out.txt 2>&1" to the
			 * command line.
			 * See <http://www.tech-archive.net/Archive/Scripting/microsoft.public.scripting.wsh/2004-10/0204.html>
			 * for a discussion on this topic.
			 */
			// Read and discard the output buffers to prevent process blocking
			/*
		    if (!shellExec.StdOut.AtEndOfStream) {
		    	dinfo("STDOUT: " + shellExec.StdOut.ReadAll());
		    }
		    if (!shellExec.StdErr.AtEndOfStream) {
		    	dinfo("STDERR: " + shellExec.StdErr.ReadAll());
		    }
		    */

			if (count >= timeout) {
				return -1;
			}
		}

		return shellExec.exitCode;
	} catch (e) {
		// handle execution exception
		var message = "Command '" + cmd + "\" was unsuccessful.\n" + e.description;
		if(isQuitOnError()) {
			throw new Error(message);
		} else {
			error(message);
			return -1;
		}
	}
}

/**
 * Returns script arguments
 */
function getArgv() {
	return WScript.Arguments;
}

/**
 * This function retrieves the IP address from the registry.
 *
 * @return array of IP address strings, array can be of length 0
 */
function getIPAddresses() {
	var addresses = new Array;

	var shell = new ActiveXObject("WScript.Shell");

	var netCards = "SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\NetworkCards\\";
	var netInterfaces = "SYSTEM\\CurrentControlSet\\Services\\Tcpip\\Parameters\\Interfaces\\";

	var subKeys = getRegistrySubkeys(netCards);
	if (subKeys != null) {
		for (var i=0; i < subKeys.length; i++) {
			// get service name entry
			var service = getRegistryValue("HKLM\\" + netCards + subKeys[i] + "\\ServiceName");
			if (service != null && service != "") {
				dinfo("Found network service: " + service);

				// check if DHCP is enabled
				var regBase = "HKLM\\" + netInterfaces +  service + "\\";
				var isDHCP = getRegistryValue(regBase + "EnableDHCP");
				if (isDHCP != null && isDHCP > 0) {
					dinfo("Reading DHCP address.");
					// read DHCP address
					var dhcpIP = getRegistryValue(regBase + "DhcpIPAddress");
					if (dhcpIP != null && dhcpIP != "") {
						addresses.push(dhcpIP);
						dinfo("Found DHCP address: " + dhcpIP);
					}
				} else {
					// try reading fixed IP
					dinfo("Reading fixed IP address(es).");

					var fixedIPs = getRegistryValue(regBase + "IPAddress").toArray();
					if (fixedIPs != null) {
						for (var j=0; j < fixedIPs.length; j++) {
							if (fixedIPs[j] != null &&
								fixedIPs[j] != "" &&
								fixedIPs[j] != "0.0.0.0") {
								addresses.push(fixedIPs[j]);
								dinfo("Found fixed IP address: " + fixedIPs[j]);
							}
						}
					}
				}
			}
		}
	}
	return addresses;
}

/**
 * Returns the windows LCID configured for the current user.
 * NOTE: The LCID is read from "HKCU\Control Panel\International\Locale"
 * This is the locale of the user under which WPKG is run. In case WPKG GUI is
 * used this might probably differ from the real locale of the user but at
 * least it will match the system default locale. A user working on an english
 * installation will most probably be able to understand english messages even
 * if the users locale might be set to german.
 * I was yet unable to find any other reliable way to read the locale.
 *
 * @return LCID value corresponding to current locale. See
 *         http://www.microsoft.com/globaldev/reference/lcid-all.mspx
 *         for a list of possible values. Leading zeroes are stripped.
 */
function getLocale() {
	if (LCID == null) {
		// set default to English - United States
		var defaultLocale = "409";
		var localePath = "HKCU\\Control Panel\\International\\Locale";

		// read the key
		var regLocale = getRegistryValue(localePath);
		if (regLocale != null) {
			// trim leading zeroes
			locale = trimLeadingZeroes(regLocale).toLowerCase();
			dinfo("Found system locale: " + locale);
			LCID = locale;
		} else {
			LCID = defaultLocale;
			dinfo("Unable to locate system locale. Using default locale: " + locale);
		}
	}

	return LCID;
}

/**
 * Returns the current value of the rebootCmd variable.
 *
 * @return current value of rebootCmd
 */
function getRebootCmd() {
	return rebootCmd;
}

/**
 * Returns a string array containing the names of the subkeys of the given
 * registry key. The parentKey parameter has to be specified without the
 * leading HKCU part.
 *
 * @param parentKey key to read subkeys from (e.g. "SOFTWARE\\Microsoft"
 *
 * @return array containing a list of strings representing the subkey names
 *         returns null in case of error or empty array in case of no available
 *         subkeys.
 */
function getRegistrySubkeys(parentKey) {
	// key representing HKEY_LOCAL_MACHINE
	var HKLM = 0x80000002;

	var returnArray = new Array();

	try {
		// Getting registry access object.
		var locator = new ActiveXObject("WbemScripting.SWbemLocator");
		var service = locator.ConnectServer(null, "root\\default");
		var regProvider = service.Get("StdRegProv");

		var enumKeyMethod = regProvider.Methods_.Item("EnumKey");
		var inputParameters = enumKeyMethod.InParameters.SpawnInstance_();
		inputParameters.hDefKey = HKLM;
		inputParameters.sSubKeyName = parentKey;
		var outputParam = regProvider.ExecMethod_(enumKeyMethod.Name, inputParameters);

		returnArray = outputParam.sNames.toArray();
	} catch(err) {
		error("Error when searching registry sub-keys at 'HKLM\\" +
				 parentKey + "'\nCode: " + hex(err.number) + "; Descriptions: " +
				 err.description);
		returnArray = null;
	}

	return returnArray;
}

/**
 * Returns value of given key in registry. If a key is specified instead of a
 * registry value returns its "(default)" value. In case no default value is
 * assigned returns an empty string ("").
 *
 * In case no such key or value exists within the registry, returns null
 *
 * @return registry value, key default value (or "") or null if path does not
 *         exist. In case the read value is a REG_DWORD returns an integer.
 *         In case the value is of type REG_MULTI_SZ returns a VBArray of
 *         strings. In case value is of type REG_BINARY returns VBArray of
 *         integer.
 */
function getRegistryValue(registryPath) {
	registryPath = trim(registryPath);
	var originalPath = registryPath;

	var WshShell = new ActiveXObject("WScript.Shell");
	var val = "";
	try {
		val = WshShell.RegRead(registryPath);
	} catch (e) {
		var readError = e.description;
		// dinfo("Error reading value at '" + registryPath + "', trying to read it as a key");

		// supplied path is probably a key, test for key existence
		if (registryPath.match(new RegExp("\\\\$", "g")) == null) {
			// dinfo("String '" + registryPath + "' is not backslash " +
			//			 "terminated, adding trailing backslash and test for key existence");

			registryPath = registryPath + "\\";
			try {
				val = WshShell.RegRead(registryPath);
			} catch (keyErr) {
				val = null;
				// readError = keyErr.description;
				// dinfo("Error reading key'" + registryPath + "': "  + readError);
			}
		}

		// force error message to get returned error string
		// in case the key does not exist
		var noSuchKeyError;
		try {
			WshShell.RegRead("HKLM\\SOFTWARE\\NOSUCHKEY\\");
		} catch (noKeyError) {
			noSuchKeyError = noKeyError.description;
			// dinfo("Error when reading inexisting key: " + noSuchKeyError);
		}
		// check if the error message we got ist the same
		if (noSuchKeyError.replace(new RegExp("HKLM\\\\SOFTWARE\\\\NOSUCHKEY\\\\"),
			registryPath) == readError) {

			// check if key exists for 32-bit applications in redirected path
			// (only if the path if not already pointing to the Wow6432Node key
			if (is64bit() &&
				originalPath.match(new RegExp("^HKLM\\\\SOFTWARE", "i")) &&
				!originalPath.match(new RegExp("^HKLM\\\\SOFTWARE\\\\Wow6432Node", "i"))) {
				// dinfo("Searching for value at 32-bit redirection node.");
				var redirectPath = originalPath.replace(new RegExp("^HKLM\\\\SOFTWARE", "i"),
														"HKLM\\Software\\Wow6432Node");
				val = getRegistryValue(redirectPath);
			} else {
				// dinfo("No such key or value at '" + registryPath + "' returning null.");
				// return null - not found
				val = null;
			}
		} else {
			// dinfo("Key found at '" + registryPath + "'.");
		}
	}

	return val;
}

/**
 * User-defined function to format error codes.
 * VBScript has a Hex() function but JScript does not.
 */
function hex(nmb) {
	if (nmb > 0) {
		return nmb.toString(16);
	} else {
		return (nmb + 0x100000000).toString(16);
	}
}

/**
 * Scans an argument vector for an argument "arg". Returns true if found, else
 * false.
 */
function isArgSet(argv, arg) {
	// Loop over argument vector and return true if we hit it...
	for (var i = 0; i < argv.length; i++) {
		if (argv(i) == arg) {
			return true;
		}
	}
	// ...otherwise, return false.
	return false;
}

/**
 * Loads environment for the specified package (including applying host and
 * profile variables).
 * 
 * NOTE: You should invoke saveEnv() before loading the package environment.
 * This allows you to call loadEnv() after operations are done to restore
 * the previous environment.
 * [...]
 * saveEnv();
 * loadPackageEnv(package);
 * // do some actions
 * loadEnv();
 * 
 * @param packageNode The package definition to load the environment from
 */
function loadPackageEnv(packageNode) {
		// Package variables first...
		var variables = getPackageVariables(packageNode, null);

		// ...then profile variables...
		getProfileVariables(variables);

		// ...and lastly host variables.
		getHostVariables(variables);

		var procEnv=new ActiveXObject("WScript.Shell").Environment("Process");
		// apply variable keys to environment
		var variableKeys = variables.keys().toArray();
		for (var i=0; i < variableKeys.length; i++) {
			var key = variableKeys[i];
			var val = variables.Item(key);
			dinfo("Variable " + key + " = " + val);
			procEnv(key) = val;
		}
}

/**
 * To restore the environment.
 */
function loadEnv() {
	var procEnv=new ActiveXObject("WScript.Shell").Environment("Process");
	for(e=new Enumerator(procEnv); !e.atEnd(); e.moveNext()) {
		var env=e.item(e);
		var RetVal = env.split("=");
		var name=RetVal[0];
		if (name!="") {
			if (oldEnv.Exists(name)) {
				procEnv(name)=oldEnv(name);
			} else {
				procEnv.Remove(name);
			}
		}
	}
}

/**
 * Parses Date according to ISO 8601. See <http://www.w3.org/TR/NOTE-datetime>.
 * Generic format example:
 * 	"YYYY-MM-DD hh:mm:ss"
 * Valid date examples:
 * 	(the following dates are all equal if ceil is set to false)
 * 	"2007-11-23 22:00"			(22:00 local time)
 * 	"2007-11-23T22:00"			(Both, "T" and space delimiter are allowed)
 * 	"2007-11-23 22:00:00"		(specifies seconds which default to 0 above)
 * 	"2007-11-23 22:00:00.000"	(specifies milliseconds which default to 0)
 * It is allowed to specify the timezone as well:
 * 	"2007-11-23 22:00+01:00"	(22:00 CET)
 * 	"2007-11-23 21:00Z"			(21:00 UTC/GMT = 22:00 CET)
 * 	"2007-11-23 22:00+00:00"	(21:00 UTC/GMT = 22:00 CET)
 *
 * If 'ceil' is set to true then unspecified date components do not fall back
 * to "floor" (basically 0) but will be extended to the next value.
 * This allows easy comparison if the current date is within a parsed "!ceil"
 * date and a parsed "ceil" date.
 * Examples:
 * ceil=false:
 * 	"2007-11-23"	=> "2007-11-23 00:00:00"
 * 	"2007-11"		=> "2007-11-01 00:00:00"
 * ceil=true:
 * 	"2007-11-23"	=> "2007-11-24 00:00:00"
 * 	"2007-11"		=> "2007-12-01 00:00:00"
 *
 * so you can specify a range in the fillowing format
 * if (parseISODate("2007-11", !ceil) >= currentDate &&
 *     parseISODate("2007-11", ceil) <= currentDate) {
 * 		// this will be true for all dates within November 2007
 * 		...
 * }
 *
 * TIMEZONES:
 * As specified by ISO 8601 the date is parsed as local date in case no
 * time zone is specified. If you define a time zone then the specified time
 * is parsed as local time for the given time zone. So if you specify
 * "2007-11-23 22:00+05:00" this will be equal to "2007-11-23 18:00+01:00"
 * while "+01:00" is known as CET as well. The special identifier "Z" is equal
 * to "+00:00" time zone offset.
 *
 * Specifying an empty string as dateString is allowed and will results in
 * returning the first of january 00:00 of the current year (ceil=false) or
 * first of january 0:00 of the next year (ceil=true).
 *
 * @param dateString the string to be parsed as ISO 8601 date
 * @param ceil definees if missing date components are "rounded-up" or "rounded down", see above
 * @return Date object representing the specified date
 */
function parseISODate(dateString, ceil) {
	// <YYYY>[-]<MM>[-]<DD>[T ]<hh>:<mm>:<ss>.<ms>[
	// make sure dateString is defined
	var now = new Date();
	if (dateString == null) {
		dateString = now.getFullYear() + "";
	}

	// http://www.w3.org/TR/NOTE-datetime
	var regexp = "([0-9]{4})(?:-?([0-9]{1,2})(?:-?([0-9]{1,2})" +
			"(?:[T ]([0-9]{1,2}):([0-9]{1,2})(?::([0-9]{1,2})(?:\\.([0-9]{1,3}))?)?" +
			"(?:(Z)|(?:([-+])([0-9]{1,2})(?::([0-9]{1,2}))?))?)?)?)?";

	// execute matching
	var matches = dateString.match(new RegExp(regexp));

	if (ceil == null) {
		ceil = false;
	}
	var offset = 0;

	// create new date object using the parsed year
	var date = new Date(now.getFullYear(), 0, 1);
	if (matches[1]) {
		date.setFullYear(matches[1]);
	} else if (ceil) {
		date.setFullYear(date.getFullYear() + 1);
	}
	// parse months
	if (matches[2]) {
		date.setMonth(matches[2] - 1);
	} else if (ceil) {
		// month not defined, advance to next year
		date.setFullYear(date.getFullYear() + 1);
		ceil = false;
	}
	// parse days (of the month)
	if (matches[3]) {
		date.setDate(matches[3]);
	} else if (ceil) {
		// date (day of the month) not defined, advance to next month
		date.setMonth(date.getMonth() + 1);
		ceil = false;
	}
	// parse hours
	if (matches[4]) {
		date.setHours(matches[4]);
	} else if (ceil) {
		// hours not defined, advance to next day
		date.setDate(date.getDate() + 1);
		ceil = false;
	}
	// parse minutes
	if (matches[5]) {
		date.setMinutes(matches[5]);
	} else if (ceil) {
		// minutes not defined, advance to next hour
		date.setHours(date.getHours() + 1);
		ceil = false;
	}
	// parse seconds
	if (matches[6]) {
		date.setSeconds(matches[6]);
	} else if (ceil) {
		// seconds not defined, advance to next minute
		date.setMinutes(date.getMinutes() + 1);
		ceil = false;
	}
	// parse milliseconds
	if (matches[7]) {
		date.setMilliseconds(Number(matches[7]));
	} else if (ceil) {
		// milliseconds not defined, advance to next second
		date.setSeconds(date.getSeconds() + 1);
		ceil = false;
	}
	// parse timezone offset
	var timeZoneSet = false;
	if (matches[8] == "Z") {
		matches[9] = 0;
		matches[10] = 0;
		timeZoneSet = true;
	}
	if (matches[9] || timeZoneSet) {
		// if offset is specified, translate time to local time
		var dateOffset = 0;
		if (matches[11]) {
			dateOffset = Number(matches[11]);
		}
		// convert to milliseconds
		dateOffset += Number(matches[10]) * 60;

		// evaluate prefix
		dateOffset *= (matches[9] == "+") ? 1 : -1;

		// calculate actual time
		// get UTC representation of the specified date in milliseconds
		time = Date.UTC(date.getFullYear(),
						date.getMonth(),
						date.getDate(),
						date.getHours(),
						date.getMinutes(),
						date.getSeconds(),
						date.getMilliseconds());

		// subtract specified offset to get UTC representation of specified date
		time -= dateOffset * 60 * 1000;

		// create new date object using the UTC time specified
		date = new Date(time);
	}

	return date;
}

/**
 * Reboots the system using tools\psshutdown.exe from the script execution
 * directoy.
 */
function psreboot() {
	if (!isNoReboot() ) {
		rebooting = true;
		// RFL prefers shutdown tool to this method: allows user to cancel
		// if required, but we loop for ever until they give in!
		// get localized message
		var msg = getLocalizedString("notifyUserReboot");
		if (msg == null) {
			msg="Rebooting to complete software installation. Please note that "+
				"some software might not work until the machine is rebooted."
		}
		// Overwrites global variable rebootcmd!
		var rebootCmd="tools\\psshutdown.exe"
		var fso = new ActiveXObject("Scripting.FileSystemObject");
			if (!fso.fileExists(rebootCmd)) {
				var path = WScript.ScriptFullName;
				var psBase = fso.GetParentFolderName(path);
				rebootCmd = fso.BuildPath(psBase, rebootCmd);
				if (!fso.fileExists(rebootCmd)) {
					throw new Error("Could not locate rebootCmd '" + rebootCmd + "'.");
				}
			}
		var shutdown=rebootCmd + " -r -accepteula ";

		cleanup();
		for (var iCountdown1 = 60; iCountdown1 != 0; iCountdown1 = iCountdown1-1) {
			// This could be cancelled.
			var cmd1 = shutdown + " -c -m \"" + msg + "\" -t " + iCountdown1;
			info("Running a shutdown command: "+ cmd1);
			exec(cmd1, 0, null);
			WScript.Sleep(iCountdown1 * 1000);
		}
		// Hmm. We're still alive. Let's get more annoying.
		for (var iCountdown2 = 60; iCountdown2 != 0; iCountdown2 = iCountdown2 - 3) {
			var cmd2 = shutdown + " -m \"" + msg + "\" -t "+ iCountdown2;
			info("Running a shutdown command: " + cmd2);
			exec(cmd2, 0, null);
			WScript.Sleep(iCountdown2 * 1000);
		}
		// And if we're here, there's problem.
		notify("This machine needs to reboot.");

	} else {
		info("System reboot was initiated but overridden.");
	}

	exit(0);
}

/**
 * Reboots the system.
 */
function reboot() {
	if (!isNoReboot() ) {
		// set global var that all functions know that a reboot is in progress
		rebooting = true;
		switch (getRebootCmd()) {
		case "standard":
			var wmi = GetObject("winmgmts:{(Shutdown)}//./root/cimv2");
			var win = wmi.ExecQuery("select * from Win32_OperatingSystem where Primary=true");
			var e = new Enumerator(win);

			info("System reboot in progress!");

			if (!isNoRunningState()) {
				// Reset running state.
				setRunningState("false");
			}
			// make sure files are written
			cleanup();
			for (; !e.atEnd(); e.moveNext()) {
				var x = e.item();
				x.win32Shutdown(6);
			}
			exit(3010);
			break;
		case "special":
			psreboot();
			break;
		default:
			var fso = new ActiveXObject("Scripting.FileSystemObject");
			if (!fso.fileExists(getRebootCmd())) {
				var path = WScript.ScriptFullName;
				var toolBase = fso.GetParentFolderName(path);
				setRebootCmd(fso.BuildPath(toolBase, getRebootCmd()));
				if (!fso.fileExists(getRebootCmd())) {
					throw new Error("Could not locate rebootCmd '" + getRebootCmd() + "'.");
				}
			}
			info("Running a shutdown command: " + getRebootCmd());
			// close files
			cleanup();
			// execute shutdown
			exec(getRebootCmd(), 0, null);
			exit(3010);
			break;
		}
	} else {
		info("System reboot was initiated but overridden.");
	}

	// exit with code "3010 << 8" (770560) which means 3010 shifted by 8 bits.
	// exiting with code 3010 will make WPKG client to initiate a reboot
	// which is unlikely to be expected because reboot command is overridden.
	exit(3010 << 8);
}

 /**
  * To save the current environment in order to allow later restore. See
  * loadEnv() method.
  */
 function saveEnv() {
 	var procEnv=new ActiveXObject("WScript.Shell").Environment("Process");
 	for(e=new Enumerator(procEnv); !e.atEnd(); e.moveNext()) {
 		var env=e.item(e);
 		var RetVal = env.split("=", 1);
 		var key = RetVal[0];
 		if (key != null && key != "") {
 			if (oldEnv.Exists(key)) {
 				oldEnv.Remove(key);
 			}
 			var valueStartOffset = key.length + 1;
 			oldEnv.add(RetVal[0], env.substr(valueStartOffset));
 		}
 	}
 }

/**
 * Scans uninstall list for given name.
 * Uninstall list is placed in registry under
 *    HKLM\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall
 * Every subkey represents package that can be uninstalled.
 * Function checks each subkey for containing value named DisplayName.
 * If this value exists, function returns true if nameSearched matches it.
 *
 * @param nameSearched The uninstall string to look for
 *                  (as it appears within control panel => add/remove software)
 * @return returns an array of registry paths to the uninstall entries found.
 *         An array is returned since the same software might be installed
 *         more than once (32-bit and 64-bit versions).
 *         Returns an empty array in case no uninstall entry could be located.
 */
function scanUninstallKeys(nameSearched) {
	var uninstallPath = new Array();
	var scanKeys = new Array();
	scanKeys.push("SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall");
	if (is64bit()) {
		// scan redirected path as well (assures that 32-bit applications are found)
		scanKeys.push("SOFTWARE\\Wow6432Node\\Microsoft\\Windows\\CurrentVersion\\Uninstall");
	}
	for (var i=0; i < scanKeys.length; i++) {
		var regPath = scanKeys[i];
		var keyNames = getRegistrySubkeys(regPath);

		for (var j=0; j < keyNames.length; j++) {
			var registryPath = "HKLM\\" + regPath + "\\" + keyNames[j];
			var displayName = getRegistryValue(registryPath + "\\DisplayName");

			if (displayName != null) {
				if (displayName == nameSearched) {
					uninstallPath.push(registryPath);
					break;
				}
			}
		}
	}
	return uninstallPath;
}

/**
 * Scans the specified array for the specified element and returns true if
 * found.
 */
function searchArray(array, element) {
	for (var i=0; i < array.length; i++) {
		var e = array[i];
		if (element == e) {
			return true;
		}
	}

	return false;
}

/**
 * Removes leading / trailing spaces.
 */
function trim(string) {
	return(string.replace(new RegExp("(^\\s+)|(\\s+$)"),""));
}

/**
 * Removes leading zeroes from a string (does not touch trailing zeroes)
 */
function trimLeadingZeroes(string) {
	return(string.replace(new RegExp("^[0]*"),""));
}

/**
 * Remove duplicate items from an array.
 */
function uniqueArray(array) {
	// Hold unique elements in a new array.
	var newArray = new Array();

	// Loop over elements.
	for (var i = 0; i < array.length; i++) {
		var found = false;
		for (var j = 0; j < newArray.length; j++) {
			if (array[i] == newArray[j]) {
				found = true;
				break;
			}
		}

		if (!found) {
			newArray.push(array[i]);
		}
	}

	return newArray;
}

/**
 * versionCompare - compare two version strings.
 * The algorithm is supposed to deliver "human" results. It's not just
 * comparing numbers but also allows versions with characters.
 * Some version number contain appendices to the version string indicating
 * "volatile" versions like "pre releases". For example some packages use
 * versions like "1.0RC1" or "1.0alpha2". Usually a version like "1.0RC1" would
 * be considered to be newer than "1.0" by the algorithm but in case of "RC"
 * versions this would be wrong. To handle such cases a number of strings are
 * defined in order to define such volatile releases.
 * The list of prefixes is defined in the global volatileReleaseMarker array.
 * Valid comparisons include:
 * A        B              Result
 * "1"      "2"            B is newer
 * "1"      "15"           B is newer
 * "1.0"    "1.2.b"        B is newer
 * "1.35"   "1.35-2"       B is newer
 * "1.35-2" "1.36"         B is newer
 * "1.35R3" "1.36"         B is newer
 * "1"      "1.0.00.0000"  Versions are equal
 * "1"      "1.0"          Versions are equal
 * "1.35"   "1.35-2"       B is newer
 * "1.35-2" "1.35"         A is newer
 * "1.35R3" "1.36R4"       B is newer
 * "1.35-2" "1.35-2.0"     Versions are equal
 * "1.35.1" "1.35.1.0"     Versions are equal
 * "1.3RC2" "1.3"          B is newer (special case where A is an "RC" version)
 * "1.5"    "1.5I3656"     A is newer (B is an "I"/intgration version)
 * "1.5"    "1.5M3656"     A is newer (B is an "M"/milestone version)
 * "1.5"    "1.5u3656"     B is newer (B is an update version)
 *
 * @return  0 if equal,<br>
 *         -1 if a < b,<br>
 *         +1 if a > b
 */
function versionCompare(a, b) {
	// first split the version into sub-versions separated by dots
	// eg. "1.00.1b20-R0" => 1, 00, 1b20-R0
	// constants defining the return values
	dinfo("Comparing version: '" + a + "' <=> '" + b + "'.");
	var BNEWER = -1;
	var ANEWER = 1;
	var EQUAL = 0;

	// small optimization, in most cases the strings will be equal.
	if (a == b) {
		return EQUAL;
	}

	var versionA = a.split(".");
	var versionB = b.split(".");
	var length = 0;
	versionA.length >= versionB.length ? length = versionA.length : length = versionB.length;
	var result = EQUAL;

	// split by sub-version-numbers
	// e.g. 1b20-R0" => 1b20, R0
	for (var i = 0; i < length; i++) {
		var versionPartsA = new Array();
		var versionPartsB = new Array();
		var partsSplitter = new RegExp("[^0-9a-zA-Z]");
		if( i < versionA.length ) {
			versionPartsA = versionA[i].split(partsSplitter);
		} else {
			// there is no such part on A side
			// assume 0
			versionPartsA.push(0);
		}
		if( i < versionB.length ) {
			versionPartsB = versionB[i].split(partsSplitter);
		} else {
			// there is no such part on B side
			// assume 0
			versionPartsB.push(0);
		}
		var versionParts = 0;
		versionPartsA.length > versionPartsB.length ? versionParts = versionPartsA.length : versionParts = versionPartsB.length;

		// split these parts into char/number fields
		// e.g "1b20" => 1, b, 20
		for (var j = 0; j < versionParts; j++) {
			// get A-side version part
			var versionPartA;
			if( j < versionPartsA.length ) {
				versionPartA = "" + versionPartsA[j];
			} else {
				// A does not have such a part, so B seems to be a higher revision
				result = BNEWER;
				break;
			}
			// get B-side version part
			var versionPartB;
			if( j < versionPartsB.length ) {
				versionPartB = "" + versionPartsB[j];
			} else {
				// B does not have such a part, so A seems to be a higher revision
				result = ANEWER;
				break;
			}
			
			// both versions have such a part, compare them
			dinfo("Comparing version fragments: '" + versionPartA + "' <=> '" + versionPartB + "'");
			
			// first split the part into number/character parts
			var numCharSplitter = new RegExp("([0-9]+)|([a-zA-Z]+)", "g");
			var numCharPartsA = versionPartA.match(numCharSplitter);
			var numCharPartsB = versionPartB.match(numCharSplitter);
			var numCharLength = 0;
			numCharPartsA.length > numCharPartsB.length ? numCharLength = numCharPartsA.length : numCharLength = numCharPartsB.length;
			// now start comparing the parts
			for (var k = 0; k < numCharLength; k++) {
				var numCharPartA;
				var numCharPartB;
				// get A-side
				if( k < numCharPartsA.length ) {
					numCharPartA = numCharPartsA[k];
				} else {
					// A-side does not have such a part, so B seems to be either
					// a higher revision or appends a volatile version identifier
					var bSideString = numCharPartsB[k];
					// check if it matches one from the volatile list
					for (var vId = 0; vId < volatileReleaseMarkers.length; vId++) {
						if (bSideString.toLowerCase() == volatileReleaseMarkers[vId]) {
							dinfo("Special case: '" + a + "' is newer because '" + b + "' " +
									"is considered to have a volatile version appendix (" +
									volatileReleaseMarkers[vId] + ").");
							result = ANEWER;
							break;
						}
					}
					if (result == EQUAL) {
						// B is newer
						result = BNEWER;
					}
					break;
				}
				if( k < numCharPartsB.length ) {
					numCharPartB = numCharPartsB[k];
				} else {
					// B-side does not have such a part, so A seems to be either
					// a higher revision or appends a volatile version identifier
					var aSideString = numCharPartsA[k];
					// check if it matches one from the volatile list
					for (var volId = 0; volId < volatileReleaseMarkers.length; volId++) {
						if (aSideString.toLowerCase() == volatileReleaseMarkers[volId]) {
							dinfo("Special case: '" + a + "' is newer because '" + b + "' " +
									"is considered to have a volatile version appendix (" +
									volatileReleaseMarkers[volId] + ").");
							result = BNEWER;
							break;
						}
					}
					if (result == EQUAL) {
						result = ANEWER;
					}
					break;
				}
				
				// both versions have such a part, compare them
				// strip off leading zeroes first
				var stripExpression = new RegExp("^[0 \t]*(.+)$")
				var strippedA = numCharPartA.match(stripExpression);
				numCharPartA = strippedA[1];

				var strippedB = numCharPartB.match(stripExpression);
				numCharPartB = strippedB[1];

				var numCharSplitA = numCharPartA.split("");
				var numCharSplitB = numCharPartB.split("");
				if (numCharSplitB.length > numCharSplitA.length) {
					// version B seems to be higher
					result = BNEWER;
					break;
				} else if (numCharSplitA.length > numCharSplitB.length) {
					// version a seems to be higher
					result = ANEWER;
					break;
				}
				
				// both versions seem to have equal length, compare them
				for (var l = 0; l < numCharSplitA.length; l++) {
					var characterA = numCharSplitA[l];
					var characterB = numCharSplitB[l];
					if (characterB > characterA) {
						// B seems to be newer
						result = BNEWER;
						break;
					} else if( characterA > characterB) {
						// A seems to be newer
						result = ANEWER
						break;
					}
				}
				
				// stop evaluating
				if(result != EQUAL) {
					break;
				}
			}
			
			// stop evaluating
			if(result != EQUAL) {
				break;
			}
		}
		
		// stop evaluating
		if(result != EQUAL) {
			break;
		}
	}

	return result;
}

