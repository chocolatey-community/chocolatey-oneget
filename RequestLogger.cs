using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using chocolatey.infrastructure.logging;
using PackageManagement.Sdk;

namespace PackageManagement
{
    public class RequestLogger : ILog
    {
        private readonly Request _request;

        public RequestLogger(Request request)
        {
            _request = request;
        }

        public void InitializeFor(string loggerName)
        {
            // TODO: I don't think I'm allowed to do this
        }

        public void Debug(string message, params object[] formatting)
        {
            _request.Debug(message, formatting);
        }

        public void Debug(Func<string> message)
        {
            _request.Debug(message.Invoke());
        }

        public void Info(string message, params object[] formatting)
        {
            _request.Verbose(message, formatting);
        }

        public void Info(Func<string> message)
        {
            _request.Verbose(message.Invoke());
        }

        public void Warn(string message, params object[] formatting)
        {
            _request.Warning(message, formatting);
        }

        public void Warn(Func<string> message)
        {
            _request.Warning(message.Invoke());
        }
        public void Error(string id, string category, string targetObject, string message)
        {
            _request.Error(id, category, targetObject, message);
        }
        public void Error(ErrorCategory category, string targetObject, string message, params object[] formatting)
        {
            _request.Error(category, targetObject, message, formatting);
        }

        public void Error(string message, params object[] formatting)
        {
            _request.Error(ErrorCategory.NotSpecified, "", message, formatting);
        }

        public void Error(Func<string> message)
        {
            _request.Error(ErrorCategory.NotSpecified, "", message.Invoke());
        }

        public void Fatal(string message, params object[] formatting)
        {
            _request.Error(ErrorCategory.NotSpecified, "FATAL", message, formatting);
        }

        public void Fatal(Func<string> message)
        {
            _request.Error(ErrorCategory.NotSpecified, "FATAL", message.Invoke());
        }
    }
}
