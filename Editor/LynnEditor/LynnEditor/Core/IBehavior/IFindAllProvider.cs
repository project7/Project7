using System;
using System.Collections.Generic;
using System.Text;

namespace LynnEditor
{
    public interface IFindAllProvider
    {
        NavPoint[] FindAll(string Keyword);
    }
}
