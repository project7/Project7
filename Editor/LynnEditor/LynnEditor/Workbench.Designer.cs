namespace LynnEditor
{
    partial class Workbench
    {
        /// <summary>
        /// 必需的设计器变量。
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// 清理所有正在使用的资源。
        /// </summary>
        /// <param name="disposing">如果应释放托管资源，为 true；否则为 false。</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows 窗体设计器生成的代码

        /// <summary>
        /// 设计器支持所需的方法 - 不要
        /// 使用代码编辑器修改此方法的内容。
        /// </summary>
        private void InitializeComponent()
        {
            this.toolStripPanelTop = new System.Windows.Forms.ToolStripPanel();
            this.menuStrip = new System.Windows.Forms.MenuStrip();
            this.menuFile = new System.Windows.Forms.ToolStripMenuItem();
            this.menuSave = new System.Windows.Forms.ToolStripMenuItem();
            this.toolStripSeparator1 = new System.Windows.Forms.ToolStripSeparator();
            this.menuExit = new System.Windows.Forms.ToolStripMenuItem();
            this.menuDebug = new System.Windows.Forms.ToolStripMenuItem();
            this.menuDebugGame = new System.Windows.Forms.ToolStripMenuItem();
            this.menuRunGame = new System.Windows.Forms.ToolStripMenuItem();
            this.toolStripMain = new System.Windows.Forms.ToolStrip();
            this.toolStripPanelBottom = new System.Windows.Forms.ToolStripPanel();
            this.statusStrip = new System.Windows.Forms.StatusStrip();
            this.statusPendingChanges = new System.Windows.Forms.ToolStripStatusLabel();
            this.toolStripPanelLeft = new System.Windows.Forms.ToolStripPanel();
            this.toolStripPanelRight = new System.Windows.Forms.ToolStripPanel();
            this.toolStripPanelTop.SuspendLayout();
            this.menuStrip.SuspendLayout();
            this.statusStrip.SuspendLayout();
            this.SuspendLayout();
            // 
            // toolStripPanelTop
            // 
            this.toolStripPanelTop.Controls.Add(this.menuStrip);
            this.toolStripPanelTop.Controls.Add(this.toolStripMain);
            this.toolStripPanelTop.Dock = System.Windows.Forms.DockStyle.Top;
            this.toolStripPanelTop.Location = new System.Drawing.Point(0, 0);
            this.toolStripPanelTop.Name = "toolStripPanelTop";
            this.toolStripPanelTop.Orientation = System.Windows.Forms.Orientation.Horizontal;
            this.toolStripPanelTop.RowMargin = new System.Windows.Forms.Padding(3, 0, 0, 0);
            this.toolStripPanelTop.Size = new System.Drawing.Size(803, 49);
            // 
            // menuStrip
            // 
            this.menuStrip.Dock = System.Windows.Forms.DockStyle.None;
            this.menuStrip.GripStyle = System.Windows.Forms.ToolStripGripStyle.Visible;
            this.menuStrip.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.menuFile,
            this.menuDebug});
            this.menuStrip.Location = new System.Drawing.Point(0, 0);
            this.menuStrip.Name = "menuStrip";
            this.menuStrip.Size = new System.Drawing.Size(803, 24);
            this.menuStrip.TabIndex = 8;
            this.menuStrip.Text = "menuStrip";
            // 
            // menuFile
            // 
            this.menuFile.DropDownItems.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.menuSave,
            this.toolStripSeparator1,
            this.menuExit});
            this.menuFile.Name = "menuFile";
            this.menuFile.Size = new System.Drawing.Size(59, 20);
            this.menuFile.Text = "文件(&F)";
            // 
            // menuSave
            // 
            this.menuSave.Name = "menuSave";
            this.menuSave.ShortcutKeys = ((System.Windows.Forms.Keys)((System.Windows.Forms.Keys.Control | System.Windows.Forms.Keys.S)));
            this.menuSave.Size = new System.Drawing.Size(177, 22);
            this.menuSave.Text = "保存工程(&S)";
            this.menuSave.Click += new System.EventHandler(this.menuSave_Click);
            // 
            // toolStripSeparator1
            // 
            this.toolStripSeparator1.Name = "toolStripSeparator1";
            this.toolStripSeparator1.Size = new System.Drawing.Size(174, 6);
            // 
            // menuExit
            // 
            this.menuExit.Name = "menuExit";
            this.menuExit.ShortcutKeyDisplayString = "Alt+F4";
            this.menuExit.Size = new System.Drawing.Size(177, 22);
            this.menuExit.Text = "退出(&X)";
            this.menuExit.Click += new System.EventHandler(this.menuExit_Click);
            // 
            // menuDebug
            // 
            this.menuDebug.DropDownItems.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.menuDebugGame,
            this.menuRunGame});
            this.menuDebug.Name = "menuDebug";
            this.menuDebug.Size = new System.Drawing.Size(59, 20);
            this.menuDebug.Text = "调试(&D)";
            // 
            // menuDebugGame
            // 
            this.menuDebugGame.Name = "menuDebugGame";
            this.menuDebugGame.ShortcutKeys = System.Windows.Forms.Keys.F12;
            this.menuDebugGame.Size = new System.Drawing.Size(171, 22);
            this.menuDebugGame.Text = "启动调试(&D)";
            this.menuDebugGame.Click += new System.EventHandler(this.menuDebugGame_Click);
            // 
            // menuRunGame
            // 
            this.menuRunGame.Name = "menuRunGame";
            this.menuRunGame.ShortcutKeys = ((System.Windows.Forms.Keys)((System.Windows.Forms.Keys.Shift | System.Windows.Forms.Keys.F12)));
            this.menuRunGame.Size = new System.Drawing.Size(171, 22);
            this.menuRunGame.Text = "运行(&R)";
            this.menuRunGame.Click += new System.EventHandler(this.menuRunGame_Click);
            // 
            // toolStripMain
            // 
            this.toolStripMain.Dock = System.Windows.Forms.DockStyle.None;
            this.toolStripMain.Location = new System.Drawing.Point(3, 24);
            this.toolStripMain.Name = "toolStripMain";
            this.toolStripMain.Size = new System.Drawing.Size(109, 25);
            this.toolStripMain.TabIndex = 7;
            this.toolStripMain.Text = "toolStrip1";
            // 
            // toolStripPanelBottom
            // 
            this.toolStripPanelBottom.Dock = System.Windows.Forms.DockStyle.Bottom;
            this.toolStripPanelBottom.Location = new System.Drawing.Point(0, 465);
            this.toolStripPanelBottom.Name = "toolStripPanelBottom";
            this.toolStripPanelBottom.Orientation = System.Windows.Forms.Orientation.Horizontal;
            this.toolStripPanelBottom.RowMargin = new System.Windows.Forms.Padding(3, 0, 0, 0);
            this.toolStripPanelBottom.Size = new System.Drawing.Size(803, 0);
            // 
            // statusStrip
            // 
            this.statusStrip.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.statusPendingChanges});
            this.statusStrip.Location = new System.Drawing.Point(0, 443);
            this.statusStrip.Name = "statusStrip";
            this.statusStrip.Size = new System.Drawing.Size(803, 22);
            this.statusStrip.TabIndex = 5;
            this.statusStrip.Text = "statusStrip1";
            // 
            // statusPendingChanges
            // 
            this.statusPendingChanges.IsLink = true;
            this.statusPendingChanges.Name = "statusPendingChanges";
            this.statusPendingChanges.Size = new System.Drawing.Size(89, 17);
            this.statusPendingChanges.Text = "尚未保存的更改";
            this.statusPendingChanges.Click += new System.EventHandler(this.statusPendingChanges_Click);
            // 
            // toolStripPanelLeft
            // 
            this.toolStripPanelLeft.Dock = System.Windows.Forms.DockStyle.Left;
            this.toolStripPanelLeft.Location = new System.Drawing.Point(0, 49);
            this.toolStripPanelLeft.Name = "toolStripPanelLeft";
            this.toolStripPanelLeft.Orientation = System.Windows.Forms.Orientation.Vertical;
            this.toolStripPanelLeft.RowMargin = new System.Windows.Forms.Padding(0, 3, 0, 0);
            this.toolStripPanelLeft.Size = new System.Drawing.Size(0, 394);
            // 
            // toolStripPanelRight
            // 
            this.toolStripPanelRight.Dock = System.Windows.Forms.DockStyle.Right;
            this.toolStripPanelRight.Location = new System.Drawing.Point(803, 49);
            this.toolStripPanelRight.Name = "toolStripPanelRight";
            this.toolStripPanelRight.Orientation = System.Windows.Forms.Orientation.Vertical;
            this.toolStripPanelRight.RowMargin = new System.Windows.Forms.Padding(0, 3, 0, 0);
            this.toolStripPanelRight.Size = new System.Drawing.Size(0, 394);
            // 
            // Workbench
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 12F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(803, 465);
            this.Controls.Add(this.toolStripPanelRight);
            this.Controls.Add(this.toolStripPanelLeft);
            this.Controls.Add(this.statusStrip);
            this.Controls.Add(this.toolStripPanelBottom);
            this.Controls.Add(this.toolStripPanelTop);
            this.IsMdiContainer = true;
            this.MainMenuStrip = this.menuStrip;
            this.Name = "Workbench";
            this.Text = "LynnEditor";
            this.toolStripPanelTop.ResumeLayout(false);
            this.toolStripPanelTop.PerformLayout();
            this.menuStrip.ResumeLayout(false);
            this.menuStrip.PerformLayout();
            this.statusStrip.ResumeLayout(false);
            this.statusStrip.PerformLayout();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.ToolStripPanel toolStripPanelTop;
        private System.Windows.Forms.ToolStripPanel toolStripPanelBottom;
        private System.Windows.Forms.StatusStrip statusStrip;
        private System.Windows.Forms.ToolStrip toolStripMain;
        private System.Windows.Forms.MenuStrip menuStrip;
        private System.Windows.Forms.ToolStripMenuItem menuDebug;
        private System.Windows.Forms.ToolStripMenuItem menuDebugGame;
        private System.Windows.Forms.ToolStripMenuItem menuRunGame;
        private System.Windows.Forms.ToolStripMenuItem menuFile;
        private System.Windows.Forms.ToolStripMenuItem menuSave;
        private System.Windows.Forms.ToolStripSeparator toolStripSeparator1;
        private System.Windows.Forms.ToolStripMenuItem menuExit;
        private System.Windows.Forms.ToolStripStatusLabel statusPendingChanges;
        private System.Windows.Forms.ToolStripPanel toolStripPanelLeft;
        private System.Windows.Forms.ToolStripPanel toolStripPanelRight;
    }
}

