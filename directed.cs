import System;
import System.Windows.Forms;
import Fiddler;
import System.Text.RegularExpressions;

class Handlers
{
    static function OnBeforeRequest(oS: Session) {
        if(oS.host.EndsWith(".yuanshen.com") || oS.host.EndsWith(".hoyoverse.com") || oS.host.EndsWith(".mihoyo.com")) {
            //This can also be replaced with another ip/domain server.
            //oS.host = "game.yuuki.me";
            oS.host = "sg2.game.yuuki.me";
            //oS.host = "2.0.0.100";
            //oS.host = "localhost";
        }
    }
};