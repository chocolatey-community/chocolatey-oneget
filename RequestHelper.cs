using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace PackageManagement
{
	using chocolatey.infrastructure.results;
	using Sdk;

	public static class RequestHelper
	{
		public static readonly char NullChar = Convert.ToChar(0x0);
		public static readonly string NullString = new string(NullChar, 1);

		public static string YieldSoftwareIdentity(this Request request, PackageResult package)
		{
			var fastPath = string.Join(NullString, package.Source, package.Package.Id, package.Version);
			var fileName = string.Format("{0}.{1}.nupkg", package.Package.Id, package.Version);
			var uri = package.SourceUri ?? (package.Package.ProjectUrl == null ? "" : package.Package.ProjectUrl.AbsoluteUri);
			return request.YieldSoftwareIdentity(
				fastPath, // this should be what we need to figure out how to find the package again
				package.Package.Id, // this is the friendly name of the package
				package.Version, "semver", // the version and version scheme
				package.Package.Summary ?? package.Package.Description, // the summary (sometimes NuGet puts it in Description?)
				package.Source, // the package SOURCE name
				package.Name, // the search that returned this package
				uri, // should be the full path to the file (I pass a project URL otherwise?)
				package.InstallLocation ?? fileName); // a file name in case they want to download it...
		}
	}
}
