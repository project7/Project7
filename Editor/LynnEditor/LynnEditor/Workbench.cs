using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;

using System.Text;
using System.Windows.Forms;
using WeifenLuo.WinFormsUI;

namespace LynnEditor
{
    public partial class Workbench : Form
    {
        private List<AbstractFile> pendingChanges = new List<AbstractFile>();

        private static Workbench instance;
        public static Workbench Instance
        {
            get {
                if (instance == null)
                    instance = new Workbench();

                return instance;
            }
        }

        public DockPanel DockPanel = new DockPanel();
        public ScriptListFile ScriptList;
        public static string scriptDir = System.IO.Path.GetFullPath(System.IO.Path.Combine(Program.ProjectPath, @"Data\\Scripts\\source\\"));
        public static string scriptListFile = System.IO.Path.Combine(scriptDir, "rakefile.info");

        private Workbench()
        {
            DockPanel.Dock = DockStyle.Fill;
            this.IsMdiContainer = true;
            DockPanel.DocumentStyle = DocumentStyles.DockingWindow;
            this.Controls.Add(DockPanel);
            InitializeComponent();

            this.Load += new EventHandler(Workbench_Load);
            this.FormClosing += new FormClosingEventHandler(Workbench_FormClosing);
        }

        void Workbench_FormClosing(object sender, FormClosingEventArgs e)
        {
            if (this.pendingChanges.Count >= 1)
            {
                DialogResult result = MessageBox.Show(this, "您已经修改了本工程。在关闭编辑器前是否需要保存呢？", this.Text, MessageBoxButtons.YesNoCancel, MessageBoxIcon.Warning, MessageBoxDefaultButton.Button1);
                switch (result)
                {
                    case DialogResult.Cancel:
                        break;
                    case DialogResult.No:
                        return;
                    case DialogResult.Yes:
                        this.SaveProject();
                        if (this.pendingChanges.Count == 0)
                            return;
                        break;
                }
                e.Cancel = true;
            }
        }

        void Workbench_Load(object sender, EventArgs e)
        {
            Program.Logger.ShowEditor();
            Program.Logger.Editor.DockState = DockState.DockBottom;

            ScriptList = new ScriptListFile(scriptListFile);
            ScriptList.ShowEditor();
            ScriptList.Editor.DockState = DockState.DockLeft;

            UpdatePendingChanges();
        }

        public void AddPendingChange(AbstractFile file)
        {
            pendingChanges.Add(file);
            UpdatePendingChanges();
        }

        void UpdatePendingChanges()
        {
            statusPendingChanges.Visible = pendingChanges.Count != 0;
        }

        private void statusPendingChanges_Click(object sender, EventArgs e)
        {
            StringBuilder sb = new StringBuilder();
            sb.AppendLine(string.Format("当前共有 {0} 个文件尚未保存：", pendingChanges.Count));
            foreach (AbstractFile file in pendingChanges)
            {
                sb.AppendLine(string.Format("  {0}: {1}；", file.GetType().Name, file.filename));
            }
            Program.Logger.Log(sb.ToString());
        }

        private void menuExit_Click(object sender, EventArgs e)
        {
            this.Close();
        }

        private void menuSave_Click(object sender, EventArgs e)
        {
            SaveProject();
        }

        public void SaveProject()
        {
            List<AbstractFile> changes = new List<AbstractFile>(pendingChanges);

            foreach (AbstractFile file in changes)
            {
                file.Commit();
                pendingChanges.Remove(file);
            }

            UpdatePendingChanges();
        }

        public void RunNormal()
        {
            System.Diagnostics.ProcessStartInfo info = new System.Diagnostics.ProcessStartInfo(System.IO.Path.Combine(Program.ProjectPath, "Game.exe"));
            Run(info);
        }

        public void RunDebug()
        {
            System.Diagnostics.ProcessStartInfo info = new System.Diagnostics.ProcessStartInfo(System.IO.Path.Combine(Program.ProjectPath, "Game.exe"), "console");
            Run(info);
        }

        public void Run(System.Diagnostics.ProcessStartInfo info)
        {
            System.Diagnostics.Process.Start(info);
        }

        private void menuDebugGame_Click(object sender, EventArgs e)
        {
            RunDebug();
        }

        private void menuRunGame_Click(object sender, EventArgs e)
        {
            RunNormal();
        }
    }
}
