using System;
using System.Collections.Generic;
using System.Text;

namespace LynnEditor
{
    public interface IFindReplaceHandler
    {
        bool CanShowFindDialog { get; }
        bool CanShowReplaceDialog { get; }
        
        void ShowFindDialog();
        void ShowReplaceDialog();
    }
}
