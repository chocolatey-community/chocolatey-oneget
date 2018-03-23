﻿//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

namespace PackageManagement
{
	using chocolatey;
	using chocolatey.infrastructure.app.configuration;
	using chocolatey.infrastructure.app.domain;
	using chocolatey.infrastructure.results;
	using NuGet;
	using Sdk;
	using System;
	using System.Collections.Generic;
	using System.Diagnostics;
	using System.Linq;
	using Constants = Sdk.Constants;

	/// <summary>
	/// A Package provider for OneGet.
	///
	/// Important notes:
	///	- Required Methods: Not all methods are required; some package providers do not support some features. If the methods isn't used or implemented it should be removed (or commented out)
	///	- Error Handling: Avoid throwing exceptions from these methods. To properly return errors to the user, use the request.Error(...) method to notify the user of an error condition and then return.
	/// </summary>
	public class ChocolateyPackageProvider
	{
		/// <summary>
		/// The features that this package supports.
		/// TODO: fill in the feature strings for this provider
		/// </summary>
		protected static Dictionary<string, string[]> Features = new Dictionary<string, string[]> {

			// specify the extensions that your provider uses for its package files (if you have any)
			{ Constants.Features.SupportedExtensions, new[]{"nupkg"}},

			// you can list the URL schemes that you support searching for packages with
			{ Constants.Features.SupportedSchemes, new [] {"http", "https", "file"}},

#if FOR_EXAMPLE
			// add this if you want to 'hide' your provider by default.
			{ Constants.Features.AutomationOnly, Constants.FeaturePresent },
#endif
			// you can list the magic signatures (bytes at the beginning of a file) that we can use

			// to peek and see if a given file is yours.
			{ Constants.Features.MagicSignatures, Constants.Signatures.ZipVariants},
		};

		private GetChocolatey _chocolatey;

		/// <summary>
		/// Returns the name of the Provider.
		/// TODO: Test and verify that we want "choco" vs "chocolatey"
		/// TODO: let's keep it as 'choco' until we are ready to punt the prototype provider
		/// </summary>
		/// <returns>The name of this provider</returns>
		public string PackageProviderName
		{
			get { return "Choco"; }
		}

		/// <summary>
		/// Returns the version of the Provider.
		/// </summary>
		/// <returns>The version of this provider </returns>
		public string ProviderVersion
		{
			get
			{
				return "3.0.0.0";
			}
		}

		/// <summary>
		/// This is just here as to give us some possibility of knowing when an unexception happens...
		/// At the very least, we'll write it to the system debug channel, so a developer can find it if they are looking for it.
		/// </summary>
		public void OnUnhandledException(string methodName, Exception exception)
		{
			Debug.WriteLine("Unexpected Exception thrown in '{0}::{1}' -- {2}\\{3}\r\n{4}", PackageProviderName, methodName, exception.GetType().Name, exception.Message, exception.StackTrace);
		}

		/// <summary>
		/// Performs one-time initialization of the $provider.
		/// </summary>
		/// <param name="request">An object passed in from the CORE that contains functions that can be used to interact with the CORE and HOST</param>
		public void InitializeProvider(Request request)
		{
			request.Debug("Entering '{0}::InitializeProvider' to set up a chocolatey with custom logging", PackageProviderName);
			_chocolatey = Lets.GetChocolatey().SetCustomLogging(new RequestLogger(request));
		}

		/// <summary>
		/// Returns dynamic option definitions to the HOST
		///
		/// example response:
		///     request.YieldDynamicOption( "MySwitch", OptionType.String.ToString(), false);
		///
		/// </summary>
		/// <param name="category">The category of dynamic options that the HOST is interested in</param>
		/// <param name="request">An object passed in from the CORE that contains functions that can be used to interact with the CORE and HOST</param>
		public void GetDynamicOptions(string category, Request request)
		{
			// TODO: improve this debug message that tells us what's going on.
			request.Debug("Entering '{0}::GetDynamicOptions' {1}", PackageProviderName, category);

			switch ((category ?? string.Empty).ToLowerInvariant())
			{
				case "install":
					// TODO: put the options supported for install/uninstall/getinstalledpackages

					break;

				case "provider":
					// TODO: put the options used with this provider (so far, not used by OneGet?).

					break;

				case "source":
					// TODO: put any options for package sources

					break;

				case "package":
					// TODO: put any options used when searching for packages

					break;
				default:
					request.Debug("Unknown category for '{0}::GetDynamicOptions': {1}", PackageProviderName, category);
					break;
			}
		}

		/// <summary>
		/// Returns a collection of strings to the client advertizing features this provider supports.
		/// </summary>
		/// <param name="request">An object passed in from the CORE that contains functions that can be used to interact with the CORE and HOST</param>
		public void GetFeatures(Request request)
		{
			request.Debug("Entering '{0}::GetFeatures' ", PackageProviderName);

			foreach (var feature in Features)
			{
				request.Yield(feature);
			}
		}

		#region Sources
		/// <summary>
		/// Resolves and returns Package Sources to the client.
		///
		/// Specified sources are passed in via the request object (<c>request.GetSources()</c>).
		///
		/// Sources are returned using <c>request.YieldPackageSource(...)</c>
		/// </summary>
		/// <param name="request">An object passed in from the CORE that contains functions that can be used to interact with the CORE and HOST</param>
		public void ResolvePackageSources(Request request)
		{
			// TODO: improve this debug message that tells us what's going on.
			request.Debug("Entering '{0}::ResolvePackageSources'", PackageProviderName);

			foreach (var source in GetSource(request.Sources.ToArray()))
			{
				request.YieldPackageSource(source.Id, source.Value, false, source.Authenticated, false);
			}
		}
        #endregion

        /// <summary>
		/// This is called when the user is adding (or updating) a package source
		/// </summary>
		/// <param name="name">The name of the package source. If this parameter is null or empty the PROVIDER should use the location as the name (if the PROVIDER actually stores names of package sources)</param>
		/// <param name="location">The location (ie, directory, URL, etc) of the package source. If this is null or empty, the PROVIDER should use the name as the location (if valid)</param>
		/// <param name="trusted">A boolean indicating that the user trusts this package source. Packages returned from this source should be marked as 'trusted'</param>
		/// <param name="request">An object passed in from the CORE that contains functions that can be used to interact with the CORE and HOST</param>
		public void AddPackageSource(string name, string location, bool trusted, Request request)
		{
			// TODO: Make chocolatey store "trusted" property on the sources
			request.Debug("Entering {0} source add -n={1} -s'{2}' (we don't support trusted = '{3}')", PackageProviderName, name,
				location, trusted);

			_chocolatey.Set(conf =>
			{
				conf.CommandName = "Source";
				conf.SourceCommand.Command = SourceCommandType.add;
				conf.SourceCommand.Name = name;
				conf.Sources = location;
				conf.AllowUnofficialBuild = true;
			}).Run();
		}

		/// <summary>
		/// Removes/Unregisters a package source
		/// </summary>
		/// <param name="name">The name or location of a package source to remove.</param>
		/// <param name="request">An object passed in from the CORE that contains functions that can be used to interact with the CORE and HOST</param>
		public void RemovePackageSource(string name, Request request)
		{
			request.Debug("Entering {0} source remove -n={1})", PackageProviderName, name);

			_chocolatey.Set(conf =>
			{
				conf.CommandName = "Source";
				conf.SourceCommand.Command = SourceCommandType.remove;
				conf.SourceCommand.Name = name;
				conf.AllowUnofficialBuild = true;
			}).Run();
			// TODO: support user-defined package sources OR remove this method
		}

		/// <summary>
		/// Searches package sources given name and version information
		///
		/// Package information must be returned using <c>request.YieldPackage(...)</c> function.
		/// </summary>
		/// <param name="name">a name or partial name of the package(s) requested</param>
		/// <param name="requiredVersion">A specific version of the package. Null or empty if the user did not specify</param>
		/// <param name="minimumVersion">A minimum version of the package. Null or empty if the user did not specify</param>
		/// <param name="maximumVersion">A maximum version of the package. Null or empty if the user did not specify</param>
		/// <param name="id">if this is greater than zero (and the number should have been generated using <c>StartFind(...)</c>, the core is calling this multiple times to do a batch search request. The operation can be delayed until <c>CompleteFind(...)</c> is called</param>
		/// <param name="request">An object passed in from the CORE that contains functions that can be used to interact with the CORE and HOST</param>
		public void FindPackage(string name, string requiredVersion, string minimumVersion, string maximumVersion, int id, Request request)
		{
			request.Debug("Entering '{0}::FindPackage' '{1}','{2}','{3}','{4}', '{5}'", PackageProviderName, name, requiredVersion, minimumVersion, maximumVersion, id);
			request.Debug("FindPackage:: " + request.PackageSources.@join("|"));
			var versions = ParseVersion(requiredVersion, minimumVersion, maximumVersion);

			var sources = GetSource(request.PackageSources.ToArray());
			// TODO: need to support URLs for sources ...
			foreach(var package in _chocolatey.Set(conf =>
				{
					conf.CommandName = "List";
					conf.Input = name;
					conf.Sources = sources.Select(cs => cs.Value).@join(";");
					conf.Version = requiredVersion;
					conf.AllowUnofficialBuild = true;
				}).List<PackageResult>())
			{
				SemanticVersion actual;
				if (SemanticVersion.TryParse(package.Version, out actual) && (actual < versions.Item1 || actual > versions.Item2))
				{
					continue;
				}
				request.YieldSoftwareIdentity(package);
			}
		}

		private static Tuple<SemanticVersion,SemanticVersion> ParseVersion(string requiredVersion, string minimumVersion, string maximumVersion)
		{
			SemanticVersion min, max, actual;

			if (!string.IsNullOrEmpty(requiredVersion) && SemanticVersion.TryParse(requiredVersion, out actual))
			{
				min = max = actual;
			}
			else
			{
				if (string.IsNullOrEmpty(minimumVersion) || !SemanticVersion.TryParse(minimumVersion, out min))
				{
					min = new SemanticVersion(new Version());
				}
				if (string.IsNullOrEmpty(maximumVersion) || !SemanticVersion.TryParse(maximumVersion, out max))
				{
					max = new SemanticVersion(int.MaxValue, int.MaxValue, int.MaxValue, int.MaxValue);
				}
			}
			return new Tuple<SemanticVersion, SemanticVersion>(min, max);
		}


		private IEnumerable<ChocolateySource> GetSource(params string[] names)
		{
			IEnumerable<ChocolateySource> sources;
			if (names.Any())
			{
				var all = new List<ChocolateySource>();
				// the system is requesting sources that match the values passed.
				// if the value passed can be a legitimate source, but is not registered, return a package source marked unregistered.

				all.AddRange( _chocolatey.Set(conf =>
				{
					conf.CommandName = "Source";
					conf.SourceCommand.Command = SourceCommandType.list;
					conf.Sources = names.@join(";");
					conf.AllowUnofficialBuild = true;
				}).List<ChocolateySource>().Where(source => names.Any(name => name == source.Id || name == source.Value)));

				if (!all.Any())
				{
					foreach (var n in names)
					{
						string name = n;
						var s = _chocolatey.Set(conf =>
						{
							conf.CommandName = "Source";
							conf.SourceCommand.Command = SourceCommandType.list;
							conf.Sources = name;
							conf.AllowUnofficialBuild = true;
						}).List<ChocolateySource>().Where(source => name == source.Id || name == source.Value).ToList();
						if (!s.Any())
						{
							all.Add(new ChocolateySource {Id = name, Value = name});
						}
						else
						{
							all.AddRange(s);
						}
					}
				}
				sources = all;
			}
			else
			{
				// the system is requesting all the registered sources
				sources = _chocolatey.Set(conf =>
				{
					conf.CommandName = "Source";
					conf.SourceCommand.Command = SourceCommandType.list;
					conf.AllowUnofficialBuild = true;
				}).List<ChocolateySource>();
			}
			return sources;
		}

/*
		/// <summary>
		/// Finds packages given a locally-accessible filename
		///
		/// Package information must be returned using <c>request.YieldPackage(...)</c> function.
		/// </summary>
		/// <param name="file">the full path to the file to determine if it is a package</param>
		/// <param name="id">if this is greater than zero (and the number should have been generated using <c>StartFind(...)</c>, the core is calling this multiple times to do a batch search request. The operation can be delayed until <c>CompleteFind(...)</c> is called</param>
		/// <param name="request">An object passed in from the CORE that contains functions that can be used to interact with the CORE and HOST</param>
		public void FindPackageByFile(string file, int id, Request request)
		{
			// TODO: improve this debug message that tells us what's going on.
			request.Debug("Entering '{0}::FindPackageByFile' '{1}','{2}'", PackageProviderName, file, id);

			// TODO: implement searching for a package by analyzing the package file, or remove this method
		}

		/// <summary>
		/// Finds packages given a URI.
		///
		/// The function is responsible for downloading any content required to make this work
		///
		/// Package information must be returned using <c>request.YieldPackage(...)</c> function.
		/// </summary>
		/// <param name="uri">the URI the client requesting a package for.</param>
		/// <param name="id">if this is greater than zero (and the number should have been generated using <c>StartFind(...)</c>, the core is calling this multiple times to do a batch search request. The operation can be delayed until <c>CompleteFind(...)</c> is called</param>
		/// <param name="request">An object passed in from the CORE that contains functions that can be used to interact with the CORE and HOST</param>
		public void FindPackageByUri(Uri uri, int id, Request request)
		{
			// TODO: improve this debug message that tells us what's going on.
			request.Debug("Entering '{0}::FindPackageByUri' '{1}','{2}'", PackageProviderName, uri, id);

			// TODO: implement searching for a package by it's unique uri (or remove this method)
		}

		/// <summary>
		/// Downloads a remote package file to a local location.
		/// </summary>
		/// <param name="fastPackageReference"></param>
		/// <param name="location"></param>
		/// <param name="request">An object passed in from the CORE that contains functions that can be used to interact with the CORE and HOST</param>
		public void DownloadPackage(string fastPackageReference, string location, Request request)
		{
			// TODO: improve this debug message that tells us what's going on.
			request.Debug("Entering '{0}::DownloadPackage' '{1}','{2}'", PackageProviderName, fastPackageReference, location);

			// TODO: actually download the package ...

		}

		/// <summary>
		/// Returns package references for all the dependent packages
		/// </summary>
		/// <param name="fastPackageReference"></param>
		/// <param name="request">An object passed in from the CORE that contains functions that can be used to interact with the CORE and HOST</param>
		public void GetPackageDependencies(string fastPackageReference, Request request)
		{
			// TODO: improve this debug message that tells us what's going on.
			request.Debug("Entering '{0}::GetPackageDependencies' '{1}'", PackageProviderName, fastPackageReference);

			// TODO: check dependencies

		}

*/

		/// <summary>
		/// Installs a given package.
		/// </summary>
		/// <param name="fastPackageReference">A provider supplied identifier that specifies an exact package</param>
		/// <param name="request">An object passed in from the CORE that contains functions that can be used to interact with the CORE and HOST</param>
		public void InstallPackage(string fastPackageReference, Request request)
		{
			request.Debug("Entering '{0}::InstallPackage' '{1}'", PackageProviderName, fastPackageReference);
			var parts = fastPackageReference.Split(RequestHelper.NullChar);
			var force = false;

			var forceStr = request.GetOptionValue("Force");
			if (!string.IsNullOrEmpty(forceStr))
			{
				bool.TryParse(forceStr, out force);
			}

			foreach (var package in  _chocolatey.Set(conf =>
			{
				conf.CommandName = "Install";
				conf.Sources = GetSource(parts[0]).Select(cs => cs.Value).@join(";");
				conf.PackageNames = parts[1];
				conf.Version = parts[2];
				conf.AllowUnofficialBuild = true;
				conf.Force = force;
			}).List<PackageResult>())
			{
				request.YieldSoftwareIdentity(package);
			}
		}

		/// <summary>
		/// Uninstalls a package
		/// </summary>
		/// <param name="fastPackageReference"></param>
		/// <param name="request">An object passed in from the CORE that contains functions that can be used to interact with the CORE and HOST</param>
		public void UninstallPackage(string fastPackageReference, Request request)
		{
			// TODO: improve this debug message that tells us what's going on (what about the dynamic parameters)
			var parts = fastPackageReference.Split(RequestHelper.NullChar);
			request.Debug("Entering '{0}::UninstallPackage' '{1}'", PackageProviderName, parts.@join("' '"));

			// TODO: add dynamic parameters for AllVersions and ForceDependencies
			foreach (var package in _chocolatey.Set(conf =>
			{
				conf.CommandName = "Uninstall";
				//conf.Sources = parts[0];
				conf.PackageNames = parts[1];
				conf.Version = parts[2];
			}).List<PackageResult>())
			{
				request.YieldSoftwareIdentity(package);
			}
		}

		/// <summary>
		/// Returns the packages that are installed
		/// </summary>
		/// <param name="name">the package name to match. Empty or null means match everything</param>
		/// <param name="requiredVersion">the specific version asked for. If this parameter is specified (ie, not null or empty string) then the minimum and maximum values are ignored</param>
		/// <param name="minimumVersion">the minimum version of packages to return . If the <code>requiredVersion</code> parameter is specified (ie, not null or empty string) this should be ignored</param>
		/// <param name="maximumVersion">the maximum version of packages to return . If the <code>requiredVersion</code> parameter is specified (ie, not null or empty string) this should be ignored</param>
		/// <param name="request">
		///     An object passed in from the CORE that contains functions that can be used to interact with
		///     the CORE and HOST
		/// </param>
		public void GetInstalledPackages(string name, string requiredVersion, string minimumVersion, string maximumVersion, Request request)
		{
			// TODO: improve this debug message that tells us what's going on.
			request.Debug("Entering '{0}::GetInstalledPackages' '{1}' '{2}' '{3}' '{4}'", PackageProviderName, name, requiredVersion, minimumVersion, maximumVersion);
			var versions = ParseVersion(requiredVersion, minimumVersion, maximumVersion);

			foreach (var package in _chocolatey.Set(conf =>
			{
				conf.CommandName = "List";
				conf.Input = name;
				conf.ListCommand.LocalOnly = true;
				conf.AllowUnofficialBuild = true;
			}).List<PackageResult>())
			{
				SemanticVersion actual;
				if (SemanticVersion.TryParse(package.Version, out actual) && (actual < versions.Item1 || actual > versions.Item2))
				{
					continue;
				}
				request.YieldSoftwareIdentity(package);
			}
		}

/*
		/// <summary>
		///
		/// </summary>
		/// <param name="fastPackageReference"></param>
		/// <param name="request">An object passed in from the CORE that contains functions that can be used to interact with the CORE and HOST</param>
		public void GetPackageDetails(string fastPackageReference, Request request)
		{
			// TODO: improve this debug message that tells us what's going on.
			request.Debug("Entering '{0}::GetPackageDetails' '{1}'", PackageProviderName, fastPackageReference);

			// TODO: This method is for fetching details that are more expensive than FindPackage* (if you don't need that, remove this method)
		}

		/// <summary>
		/// Initializes a batch search request.
		/// </summary>
		/// <param name="request">An object passed in from the CORE that contains functions that can be used to interact with the CORE and HOST</param>
		/// <returns></returns>
		public int StartFind(Request request)
		{
			// TODO: improve this debug message that tells us what's going on.
			request.Debug("Entering '{0}::StartFind'", PackageProviderName);

			// TODO: batch search implementation
			return default(int);
		}

		/// <summary>
		/// Finalizes a batch search request.
		/// </summary>
		/// <param name="id"></param>
		/// <param name="request">An object passed in from the CORE that contains functions that can be used to interact with the CORE and HOST</param>
		/// <returns></returns>
		public void CompleteFind(int id, Request request)
		{
			// TODO: improve this debug message that tells us what's going on.
			request.Debug("Entering '{0}::CompleteFind' '{1}'", PackageProviderName, id);
			// TODO: batch search implementation
		}
*/
	}
}
