using System;
using System.Collections.Generic;
using System.Text;
using ScintillaNet;
using System.Drawing;
using WeifenLuo.WinFormsUI;
using System.Windows.Forms;

namespace LynnEditor.Debugger
{
    public class ProcessStandardStreamEditor: AbstractEditor , IClipboardHandler, ISelectAllHandler
    {
        public Scintilla Editor;

        public ProcessStandardStreamEditor(ProcessStandardStreamFile file)
            : base(file)
        {
            this.DockableAreas |= DockAreas.DockBottom | DockAreas.DockLeft | DockAreas.DockRight | DockAreas.DockTop | DockAreas.Float;

            Editor = new Scintilla();
            Editor.Dock = DockStyle.Fill;
            Editor.Font = new Font("雅黑宋体", 12);
            this.Controls.Add(Editor);

            Editor.UndoRedo.IsUndoEnabled = false;
            Editor.Text = file.Buffer;

            // http://ondineyuga.com/svn/RGE2/Tools/RGESEditor/RGESEditor_lang/EditorScintilla/Scintilla.cs
            // line number
            Editor.Margins[0].Width = 39;

            // fold
            Editor.Margins[1].Type = MarginType.Symbol;
            Editor.Margins[1].Mask = -33554432; //SC_MASK_FOLDERS
            Editor.Margins[1].Width = 16;
            Editor.Margins[1].IsClickable = true;
            Editor.NativeInterface.SetProperty("fold", "1");
            Editor.NativeInterface.SetProperty("fold.comment", "0");
            Editor.NativeInterface.SetProperty("fold.compact", "1");
            Editor.NativeInterface.SetProperty("fold.preprocessor", "1");

            Editor.Folding.Flags = FoldFlag.LineAfterContracted;

            // lexing
            Editor.Lexing.Lexer = Lexer.Ruby;
            Editor.Lexing.SetKeywords(0, "__FILE__ __LINE__ BEGIN END alias and begin break case class def defined? do else elsif end ensure false for if in module next nil not or redo rescue retry return self super then true undef unless until when while yield");
            Editor.Styles.ClearAll();
            Editor.UseFont = true;
            Editor.Styles[(int)SCE_RB.DEFAULT].ForeColor = Color.FromArgb(0, 0, 0);
            Editor.Styles[(int)SCE_RB.DEFAULT].BackColor = Color.FromArgb(255, 255, 255);
            Editor.Styles[(int)SCE_RB.WORD].ForeColor = Color.FromArgb(0, 0, 127);
            Editor.Styles[(int)SCE_RB.WORD_DEMOTED].ForeColor = Color.FromArgb(0, 0, 127);
            Editor.Styles[(int)SCE_RB.STRING].ForeColor = Color.FromArgb(127, 0, 151);
            Editor.Styles[(int)SCE_RB.GLOBAL].ForeColor = Color.FromArgb(180, 0, 180);
            Editor.Styles[(int)SCE_RB.CLASSNAME].ForeColor = Color.FromArgb(0, 0, 255);
            Editor.Styles[(int)SCE_RB.MODULE_NAME].ForeColor = Color.FromArgb(160, 0, 160);
            Editor.Styles[(int)SCE_RB.CLASS_VAR].ForeColor = Color.FromArgb(128, 0, 204);
            Editor.Styles[(int)SCE_RB.INSTANCE_VAR].ForeColor = Color.FromArgb(176, 0, 128);
            Editor.Styles[(int)SCE_RB.NUMBER].ForeColor = Color.FromArgb(0, 127, 127);
            Editor.Styles[(int)SCE_RB.STRING_Q].ForeColor = Color.FromArgb(127, 0, 151);
            Editor.Styles[(int)SCE_RB.STRING_QQ].ForeColor = Color.FromArgb(127, 0, 151);
            Editor.Styles[(int)SCE_RB.STRING_QX].ForeColor = Color.FromArgb(127, 0, 151);
            Editor.Styles[(int)SCE_RB.STRING_QR].ForeColor = Color.FromArgb(127, 0, 151);
            Editor.Styles[(int)SCE_RB.STRING_QW].ForeColor = Color.FromArgb(127, 0, 151);
            Editor.Styles[(int)SCE_RB.REGEX].ForeColor = Color.FromArgb(120, 0, 170);
            Editor.Styles[(int)SCE_RB.SYMBOL].ForeColor = Color.FromArgb(205, 100, 30);
            Editor.Styles[(int)SCE_RB.DEFNAME].ForeColor = Color.FromArgb(0, 127, 127);
            Editor.Styles[(int)SCE_RB.BACKTICKS].ForeColor = Color.FromArgb(160, 65, 10);
            Editor.Styles[(int)SCE_RB.HERE_DELIM].ForeColor = Color.FromArgb(0, 137, 0);
            Editor.Styles[(int)SCE_RB.HERE_Q].ForeColor = Color.FromArgb(127, 0, 151);
            Editor.Styles[(int)SCE_RB.HERE_QQ].ForeColor = Color.FromArgb(127, 0, 151);
            Editor.Styles[(int)SCE_RB.HERE_QX].ForeColor = Color.FromArgb(0, 137, 0);
            Editor.Styles[(int)SCE_RB.DATASECTION].ForeColor = Color.FromArgb(127, 0, 0);
            Editor.Styles[(int)SCE_RB.COMMENTLINE].ForeColor = Color.FromArgb(0, 127, 0);
            Editor.Styles[(int)SCE_RB.POD].ForeColor = Color.FromArgb(0, 127, 0);

            Editor.EndOfLine.Mode = EndOfLineMode.Crlf;
            Editor.LineWrap.Mode = ScintillaNet.WrapMode.Char;

            Editor.Indentation.UseTabs = false;
            Editor.Indentation.TabIndents = true;
            Editor.Indentation.TabWidth = 2;
            Editor.Indentation.ShowGuides = false;
            Editor.Indentation.BackspaceUnindents = true;
            Editor.Indentation.IndentWidth = 2;
            Editor.Indentation.SmartIndentType = SmartIndent.Simple;

            Editor.LongLines.EdgeMode = EdgeMode.Line;
            Editor.LongLines.EdgeColumn = 160;

            Editor.Caret.HighlightCurrentLine = true;
            Editor.Caret.CurrentLineBackgroundColor = Color.FromArgb(240, 240, 240);
            Editor.Scrolling.HorizontalWidth = 1;
        }

        public bool CanCut
        {
            get { return this.Editor.Selection.Length != 0 && !this.Editor.IsReadOnly; }
        }

        public bool CanCopy
        {
            get { return this.Editor.Selection.Length != 0; }
        }

        public bool CanPaste
        {
            get { return this.Editor.Clipboard.CanPaste; }
        }

        public void Cut()
        {
            this.Editor.Clipboard.Cut();
        }

        public void Copy()
        {
            this.Editor.Clipboard.Copy();
        }

        public void Paste()
        {
            this.Editor.Clipboard.Paste();
        }

        public bool CanSelectAll
        {
            get { return this.Editor.TextLength > 0; }
        }

        public void SelectAll()
        {
            this.Editor.Selection.SelectAll();
        }

        delegate void AppendCallback(string msg);
        public void Append(string msg)
        {
			if (this.Editor.InvokeRequired)
			{	
				AppendCallback d = new AppendCallback(Append);
				this.Invoke(d, new object[] { msg });
			}
			else
			{
                this.Editor.Text += msg;
			}
		}
    }
}
