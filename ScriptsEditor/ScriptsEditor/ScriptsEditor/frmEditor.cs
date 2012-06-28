using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.IO;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using ICSharpCode.TextEditor.Document;
using ICSharpCode;
using System.Collections;
using ICSharpCode.TextEditor;

namespace ScriptsEditor
{

    public partial class frmEditor : Form
    {
        public string myname = "";
        public string mypath = "";
        public TextEditor.FindAndReplaceForm FRWindow;
        bool dirty = false;
        public frmEditor(string path, string name)
        {
            InitializeComponent();
            myname = name;
            mypath = path;
            textEditorControl1.Document.FoldingManager.FoldingStrategy = new RubyFoldingStrategy();
            this.Text = name;
            HighlightingManager.Manager.AddSyntaxModeFileProvider(
    new FileSyntaxModeProvider("./"));
            LoadFile(path);
            FRWindow = new TextEditor.FindAndReplaceForm();
            textEditorControl1.Document.FoldingManager.UpdateFoldings(String.Empty, null);
            textEditorControl1.ActiveTextAreaControl.TextArea.Refresh();
        }
        public void LoadFile(string fileName)
        {
            if (!File.Exists(fileName)) { MessageBox.Show("获取脚本失败！"); return; }
            textEditorControl1.LoadFile(fileName);
            textEditorControl1.Document.HighlightingStrategy
                = HighlightingManager.Manager.FindHighlighter("RUBY");
            textEditorControl1.ShowSpaces = false;
            textEditorControl1.ShowTabs = false;
            textEditorControl1.ShowEOLMarkers = false;
        }

        private void textEditorControl1_Load(object sender, EventArgs e)
        {
            dirty = false;
            rename();
        }

        private void textEditorControl1_Changed(object sender, EventArgs e)
        {
            dirty = true;
            //rename();
        }

        private void button1_Click(object sender, EventArgs e)
        {
            save();
           
        }
        public void save()
        {
            dirty = false;
            this.Text = myname;
            textEditorControl1.SaveFile(mypath);
            textEditorControl1.Document.FoldingManager.UpdateFoldings(String.Empty, null);
            textEditorControl1.ActiveTextAreaControl.TextArea.Refresh();
        }
        public void rename()
        {
            if (dirty)
            {
                this.Text = " * " + myname;
            }
            else
            {
                this.Text = myname;
            }
        }

        private void 搜索ToolStripMenuItem_Click(object sender, EventArgs e)
        {
            FRWindow.ShowFor(textEditorControl1, false);
        }

        private void toolStripMenuItem2_Click(object sender, EventArgs e)
        {
            FRWindow.ShowFor(textEditorControl1, true);
        }

        private void 全选ToolStripMenuItem_Click(object sender, EventArgs e)
        {
            DoEditAction(textEditorControl1, new ICSharpCode.TextEditor.Actions.SelectWholeDocument());
        }
        private bool HaveSelection()
        {
            return textEditorControl1 != null &&
                textEditorControl1.ActiveTextAreaControl.TextArea.SelectionManager.HasSomethingSelected;
        }

        private void frmEditor_FormClosing(object sender, FormClosingEventArgs e)
        {
            DialogResult dr = MessageBox.Show("要保存您对该文件进行的修改吗？", "保存", MessageBoxButtons.YesNoCancel, MessageBoxIcon.Question, MessageBoxDefaultButton.Button1);
            if (dr == DialogResult.Yes)
            {
                save();
            }
            if (dr == DialogResult.Cancel)
            {
                e.Cancel = true;
            }
        }
        private void DoEditAction(TextEditorControl editor, ICSharpCode.TextEditor.Actions.IEditAction action)
        {
            if (editor != null && action != null)
            {
                TextArea area = editor.ActiveTextAreaControl.TextArea;
                editor.BeginUpdate();
                try
                {
                    lock (editor.Document)
                    {
                        action.Execute(area);
                        if (area.SelectionManager.HasSomethingSelected && area.AutoClearSelection /*&& caretchanged*/)
                        {
                            if (area.Document.TextEditorProperties.DocumentSelectionMode == DocumentSelectionMode.Normal)
                            {
                                area.SelectionManager.ClearSelection();
                            }
                        }
                    }
                }
                finally
                {
                    editor.EndUpdate();
                    area.Caret.UpdateCaretPosition();
                }
            }
        }
        private void 复制ToolStripMenuItem_Click(object sender, EventArgs e)
        {
            if (HaveSelection())
                DoEditAction(textEditorControl1, new ICSharpCode.TextEditor.Actions.Copy());
        }

        private void 黏贴ToolStripMenuItem_Click(object sender, EventArgs e)
        {
            DoEditAction(textEditorControl1, new ICSharpCode.TextEditor.Actions.Paste());
        }

        private void toolStripMenuItem1_Click(object sender, EventArgs e)
        {
            if (HaveSelection())
                DoEditAction(textEditorControl1, new ICSharpCode.TextEditor.Actions.Cut());
        }

        private void 撤销ToolStripMenuItem_Click(object sender, EventArgs e)
        {
            textEditorControl1.Document.UndoStack.Undo();
        }

        private void 重做ToolStripMenuItem_Click(object sender, EventArgs e)
        {
            textEditorControl1.Document.UndoStack.Redo();
        }
    }
    public class RubyFoldStart
    {
        int line = 0;
        int col = 0;
        string name = String.Empty;
        string foldText = String.Empty;
        public RubyFoldStart(string name, int line, int col)
        {
            this.line = line;
            this.col = col;
            this.name = name;
        }
        /// <summary>
        /// The line where the fold should start.  Lines start from 0.
        /// </summary>
        public int Line
        {
            get
            {
                return line;
            }
        }

        /// <summary>
        /// The column where the fold should start.  Columns start from 0.
        /// </summary>
        public int Column
        {
            get
            {
                return col;
            }
        }

        /// <summary>
        /// The name of the xml item with its prefix if it has one.
        /// </summary>
        public string Name
        {
            get
            {
                return name;
            }
        }

        /// <summary>
        /// The text to be displayed when the item is folded.
        /// </summary>
        public string FoldText
        {
            get
            {
                return foldText;
            }

            set
            {
                foldText = value;
            }
        }
    }
    public class RubyFoldingStrategy : IFoldingStrategy
    {
        bool showAttributesWhenFolded = false;
        Dictionary<string, string> pairof = new Dictionary<string, string>();
        public RubyFoldingStrategy()
        {
            pairof["if"] = "end";
            pairof["unless"] = "end";
            pairof["while"] = "end";
            pairof["for"] = "end";
            pairof["def"] = "end";
            pairof["class"] = "end";
            pairof["module"] = "end";
            pairof["do"] = "end";
            pairof["case"] = "end";
            pairof["begin"] = "end";
        }
        public List<FoldMarker> GenerateFoldMarkers(IDocument document, string fileName, object parseInformation)
        {
            showAttributesWhenFolded = true;
            List<FoldMarker> foldMarkers = new List<FoldMarker>();
            Stack stack = new Stack();
            try
            {
                string[] script = document.TextContent.Split('\n'); int lines = 0;
                bool bigHide = false;
                RubyFoldStart bigHideStart = new RubyFoldStart("no",0,0);
                foreach (string line in script)
                {
                    if (bigHide && line.Trim().StartsWith("=end")) { 
                        bigHide = false;
                        if (!(bigHideStart.Name == "no"))
                        {
                            FoldMarker fm = new FoldMarker(document, bigHideStart.Line, bigHideStart.Column, lines, line.Length);
                            foldMarkers.Add(fm);
                            bigHideStart = new RubyFoldStart("no", 0, 0);
                        }
                        lines++; 
                        continue; 
                    }

                    if (line.Trim().StartsWith("=begin")) { bigHide = true; lines++; bigHideStart = new RubyFoldStart("=begin", lines - 1, 1) ; continue; }
                    if (line.Trim().StartsWith("=__END__")) break;
                    if (line.Trim().StartsWith("#")) { lines++; continue; }
                    string[] symbols = line.Trim().Split(';');
                    int cols = line.Length-line.TrimStart(' ').Length;
                    
                    foreach (string symbol in symbols)
                    {
                        char[] chars = new char[1]; chars[0] = ' ';
                        string[] datas = symbol.Split(' ');
                        bool flagFirst = true;
                        foreach (string data in datas)
                        {
                            //string data = datas[0].Replace("\r\n", "\n");
                            string single = data.Trim();
                            if (pairof.ContainsKey(single) && flagFirst || single=="do")
                            {
                                // Start
                                RubyFoldStart rfs = new RubyFoldStart(single, lines, cols);
                                stack.Push(rfs);
                            }
                            else
                            {
                                if (pairof.ContainsValue(single))
                                {
                                    RubyFoldStart rfs = (RubyFoldStart)stack.Pop();
                                    if (pairof[rfs.Name] == single)
                                    {
                                        FoldMarker fm;
                                        if (rfs.Name =="class"||rfs.Name =="module")
                                            fm = new FoldMarker(document, rfs.Line, rfs.Column, lines, cols + data.Length,FoldType.TypeBody,script[rfs.Line].Trim());
                                        else
                                            fm = new FoldMarker(document, rfs.Line, rfs.Column, lines, cols + data.Length, FoldType.MemberBody, script[rfs.Line].Trim());
                                        foldMarkers.Add(fm);
                                    }
                                }
                                //   }
                            }
                            cols += data.Length + 1;
                            if ((cols < symbol.Length - 1))
                            {
                                while (symbol[cols] == ' ' && (cols < symbol.Length - 1)) cols++;
                            }
                            //cols += 1;
                            flagFirst = false;
                        }
                    }
                    lines++;
                }
            }
            catch (Exception)
            {
                return new List<FoldMarker>(document.FoldingManager.FoldMarker);
            }
            return foldMarkers;
        }

    }
}

