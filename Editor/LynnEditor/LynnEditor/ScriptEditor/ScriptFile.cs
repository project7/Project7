using System;
using System.Collections.Generic;

using System.Text;

namespace LynnEditor
{
    public class ScriptFile : AbstractFile
    {
        public string Code;

        public ScriptFile(string filename) : base(filename)
        {
            this.Code = System.IO.File.ReadAllText(filename, Encoding.UTF8);
        }

        public ScriptFile(string filename, string code)
            : base(filename)
        {
            this.Code = code;
        }

        protected override void Save()
        {
            System.IO.File.WriteAllText(this.filename, this.Code, Encoding.UTF8);
        }

        public override AbstractEditor CreateEditor()
        {
            return new ScriptEditor(this);
        }
    }
}
