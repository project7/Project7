using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.IO;

namespace ScriptsEditor
{
    public partial class frmMain : Form
    {
        ScriptManager sm;
        public frmMain()
        {
            InitializeComponent();
            sm = new ScriptManager(listBox1);
            sm.redraw();
        }

        private void button4_Click(object sender, EventArgs e)
        {

        }

        private void button3_Click(object sender, EventArgs e)
        {

        }

        private void button2_Click(object sender, EventArgs e)
        {

        }

        private void button5_Click(object sender, EventArgs e)
        {
            if (MessageBox.Show("执行本操作将会导致您保存前的所有修改失效，继续？","警告",MessageBoxButtons.YesNo,MessageBoxIcon.Question,MessageBoxDefaultButton.Button1) ==DialogResult.Yes)
                sm.redraw();
        }

        private void listBox1_SelectedIndexChanged(object sender, EventArgs e)
        {

        }

        private void listBox1_DoubleClick(object sender, EventArgs e)
        {
            sm.OpenScript((string)listBox1.SelectedItem);
        }

        private void 上移ToolStripMenuItem_Click(object sender, EventArgs e)
        {
            if (listBox1.SelectedIndex > 0)
            {
                string old = (string)listBox1.SelectedItem;
                int oindex = listBox1.SelectedIndex;
                listBox1.Items.RemoveAt(oindex);
                listBox1.Items.Insert(oindex - 1, old);
                sm.saveList();
            }
        }

        private void 下移ToolStripMenuItem_Click(object sender, EventArgs e)
        {
            if (listBox1.SelectedIndex < listBox1.Items.Count - 1 && listBox1.SelectedIndex!=-1)
            {
                string old = (string)listBox1.SelectedItem;
                int oindex = listBox1.SelectedIndex;
                listBox1.Items.RemoveAt(oindex);
                listBox1.Items.Insert(oindex + 1, old);
                sm.saveList();
            }
        }

        private void 删除ToolStripMenuItem_Click(object sender, EventArgs e)
        {
            if (MessageBox.Show("执行本操作将会导致该脚本被销毁，同时保存其副本为.rb.bak文件", "警告", MessageBoxButtons.YesNo, MessageBoxIcon.Question, MessageBoxDefaultButton.Button1) == DialogResult.Yes)
            {
                string old = (string)listBox1.SelectedItem;
                int oindex = listBox1.SelectedIndex;
                listBox1.Items.RemoveAt(oindex);
                File.Copy("./Data/Scripts/source/" + old + ".rb", "./Data/Scripts/source/" + old + ".rb.bak");
                File.Delete("./Data/Scripts/source/" + old + ".rb");
                
                sm.saveList();
            }
        }

        private void 新建ToolStripMenuItem_Click(object sender, EventArgs e)
        {
            string input = Microsoft.VisualBasic.Interaction.InputBox("请输入脚本名字（不可重复，不允许使用中文）", "新建脚本", "Unnamed Script", 0, 0);
            if (input != "")
            {
                string path="./Data/Scripts/source/" + input + ".rb";
                if (!File.Exists(path))
                {
                    if (File.Exists(path + ".bak"))
                    {
                        if (MessageBox.Show("检测到备份过的同名脚本，恢复？", "恢复脚本", MessageBoxButtons.YesNo, MessageBoxIcon.Question, MessageBoxDefaultButton.Button1) == DialogResult.Yes)
                        {
                            File.Copy(path+".bak",path);
                            File.Delete(path + ".bak");
                            listBox1.Items.Add(input);
                            sm.saveList();
                            return;
                        }
                    }
                    File.WriteAllText(path, "#encoding:utf-8", Encoding.UTF8);
                    listBox1.Items.Add(input);
                    sm.saveList();
                }
            }
        }

        private void 重命名ToolStripMenuItem_Click(object sender, EventArgs e)
        {
            if (listBox1.SelectedIndex >= 0)
            {
                string input = Microsoft.VisualBasic.Interaction.InputBox("请输入脚本名字（不可重复，不允许使用中文）", "新建脚本", (string)listBox1.SelectedItem, 0, 0);

                if (input.Trim() != "")
                {
                    string path = "./Data/Scripts/source/" + input + ".rb";
                    string oldpath = "./Data/Scripts/source/" + (string)listBox1.SelectedItem + ".rb";
                    if (!File.Exists(path))
                    {
                        File.Copy(oldpath,path);
                        File.Delete(oldpath);
                        string old = (string)listBox1.SelectedItem;
                        int oldidx = listBox1.SelectedIndex;
                        listBox1.Items.RemoveAt(oldidx);
                        listBox1.Items.Insert(oldidx, input);
                        sm.rename(old, input);
                        sm.saveList();

                    }
                }
            }
        }

        private void button1_Click(object sender, EventArgs e)
        {
            sm.saveAll();
        }

        private void frmMain_FormClosing(object sender, FormClosingEventArgs e)
        {
            DialogResult dr = MessageBox.Show("要保存您对该文件进行的修改吗？", "保存", MessageBoxButtons.YesNoCancel, MessageBoxIcon.Question, MessageBoxDefaultButton.Button1);
            if (dr == DialogResult.Yes)
            {
                sm.saveAll();
            }
            if (dr == DialogResult.Cancel)
                e.Cancel = false;
        }
    }
}
