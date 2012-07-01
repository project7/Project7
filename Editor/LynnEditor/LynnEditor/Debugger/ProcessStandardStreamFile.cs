using System;
using System.Collections.Generic;
using System.Text;
using System.Diagnostics;

namespace LynnEditor.Debugger
{
    public class ProcessStandardStreamFile : AbstractFile
    {
        public string Buffer;
        public Process Process;

        public ProcessStandardStreamFile(Process Process)
            : base(String.Format(@"\\.\Process\{0}", Process.Id))
        {
            this.Process = Process;
            Process.ErrorDataReceived += delegate(object sender, DataReceivedEventArgs e) { Write(e.Data); };
            Process.OutputDataReceived += delegate(object sender, DataReceivedEventArgs e) { Write(e.Data); };
            Process.BeginErrorReadLine();
            Process.BeginOutputReadLine();
        }

        public override string ToString()
        {
            return String.Format("进程 {0}:{1} 标准流", Process.ProcessName, Process.Id);
        }

        protected override void Save()
        {
            return;
        }

        public override AbstractEditor CreateEditor()
        {
            return new ProcessStandardStreamEditor(this);
        }

        public void Write(string text)
        {
            this.Buffer += text;

            if (this.Editor != null)
                (this.Editor as ProcessStandardStreamEditor).Append(text);
        }
    }
}