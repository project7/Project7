using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.IO;
namespace ScriptsEditor
{
    public class ScriptManager
    {
        Dictionary<string, frmEditor> scripts = new Dictionary<string,frmEditor>();
        ListBox lv;
        public ScriptManager(ListBox _lv)
        {
            lv = _lv;
            lv.Items.Clear();
        }
        public void redraw()
        {
            lv.Items.Clear();
            foreach (KeyValuePair<string, frmEditor> pair in scripts)
            {
                pair.Value.Close();
                pair.Value.Dispose();
            }
            scripts.Clear();
            string[] s = File.ReadAllLines("./Data/Scripts/source/rakefile.info");
            foreach (string name in s)
            {
                if (name.Trim()=="") continue;
                lv.Items.Add(name);
            }
        }
        public void OpenScript(string path)
        {
            if (scripts.ContainsKey(path) && !scripts[path].IsDisposed)
            {
                scripts[path].Show();
            }
            else
            {
                scripts[path] = new frmEditor("./Data/Scripts/source/" + path + ".rb", path);
            }
        }
        public void saveAll()
        {
            foreach (KeyValuePair<string, frmEditor> pair in scripts)
            {
                pair.Value.save();
            }
            saveList();
        }
        public void saveList()
        {
            FileStream fs = File.OpenWrite("./Data/Scripts/source/rakefile.info");
            StreamWriter sw = new StreamWriter(fs);
            foreach (string s in lv.Items)
            {
                if (s.Trim() == "") continue;
                sw.WriteLine(s);
            }
            sw.Close();
            fs.Close();
        }
        public void delete(string name)
        {
            if (scripts.ContainsKey(name))
            {
                scripts[name].Close();
                scripts[name].Dispose();
                scripts.Remove(name);
            }
        }
        public void rename(string name,string newname)
        {
            if (scripts.ContainsKey(name))
            {
                scripts[newname] = scripts[name];
                scripts.Remove(name);
                scripts[newname].myname = newname;
                scripts[newname].mypath = "./Data/Scripts/source/" + newname + ".rb";
                scripts[newname].rename();
            }
        }
    }
}
