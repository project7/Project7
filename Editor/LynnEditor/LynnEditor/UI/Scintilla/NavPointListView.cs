using System;
using System.Collections.Generic;
using System.Text;
using ScintillaNet;

namespace LynnEditor.UI
{
    public class NavPointListView : Scintilla
    {
        private List<NavPoint> items;

        public NavPointListView()
        {
            items = new List<NavPoint>();

            this.IsReadOnly = true;
            this.Margins[0].Width = 39;

            this.Lexing.Lexer = Lexer.ErrorList;
            //this.Lexing.Lexer = Lexer.Container;
            //this.StyleNeeded += new EventHandler<StyleNeededEventArgs>(NavPointListView_StyleNeeded);
        }

        public void AddItem(NavPoint pt)
        {
            if (items.Contains(pt)) return;
            items.Add(pt);
            this.IsReadOnly = false;
            this.AppendText(pt.ToString());
            this.AppendText(Environment.NewLine);
            this.IsReadOnly = true;
        }

        void NavPointListView_StyleNeeded(object sender, StyleNeededEventArgs e)
        {
            
        }
    }
}
