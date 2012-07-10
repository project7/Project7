using System;
using System.Collections.Generic;
using System.Text;

namespace LynnEditor
{
    public class NavPoint
    {
        public string FileIdentify;
        public NavPoint(string FileIdentify)
        {
            this.FileIdentify = FileIdentify;
        }

        public void Goto()
        {
            FileManager.Find(this.FileIdentify).Goto(this);
        }

        public override string ToString()
        {
            return this.FileIdentify;
        }
    }
}
