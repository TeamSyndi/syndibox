# SyndiBox Text Engine
The SyndiBox Text Engine is a powerful dialog tool designed for use in RPGs and sidescrollers. It contains a tag system for denoting changes in color, speed, and position of text.

## Installing
You can download the latest version at the Release tab, or you can clone from the master branch and edit the engine yourself.

Once downloaded, unzip the `addons` folder to the root of your project.

You should now see `SyndiBox` as an option for your plugins under the `Plugins` tab of your `Project Settings`. Set the plugin to `Active` to use it in your project.

## Usage Guide
SyndiBox is meant to be an easy and stress-free way of implementing dialog into your Godot game projects. Here's an illustrated guide on the basics:

 1. Add a child Node to your Scene.![Add a child Node to your Scene.](https://imgur.com/4CxIqcX.png)
 2. Search for `SyndiBox` and click `Create`.![Search for "SyndiBox" and click "Create".](https://imgur.com/m3nZt1o.png)
 3. Position the Node to your preferred space on the screen.![Position your Node.](https://imgur.com/U22RfM3.png)
 4. Fill the properties in the Inspector with your dialog, auto advance, font, text voice, color, and text speed. You can use what is filled in the image below as an example.![Fill the Inspector properties.](https://imgur.com/0POjPSz.png)
 5. Press the `Play Scene` button (or `F6` on your keyboard) and watch it print!![There it is~](https://imgur.com/Fiigoty.png)

## Script Guide
Syndibox exposes some functions for use within GDScript that allow for dynamic control of the text and effects.   

`start(string: dialog, int: start_position)` - Resets, shows, and starts the dialog box, displaying the given string. Passing a string to start is functionally the same as entering the string as `Dialog` in the inspector.  
- **dialog** The string to display. A value of '' replays whatever the current Dialog set contains. Defaults to ''.  
- **start_position** Start position of the text. Defaults to 0.  

`stop(boolean: emit_signal)` - Resets and stops the dialog box. This method will optionally emit a signal 'text_finished' if you set emit_signal to true.  
- **emit_signal** Defaults to true.  

`manual_text_pause` - Boolean variable used to manually pause text processing. Defaults to false. Use `resume()` to resume normal processing (see below)  

`manual_text_hide` - Boolean variable used to manually hide text. Defaults to false. Use `resume()` to resume normal processing (see below)  

`resume(boolean: resume_Printing, boolean: show_Text, boolean: resume_Advancement)` - Resumes printing process that was manually paused or hidden   
- **resume_Printing** Defaults to true.  
- **show_Text** Shows Defaults to true.  
- **resume_Advancement** Defaults to true.  


## Text Effects
We can add special effect tags to make our text much prettier than a mock console gag. Something like this:![Very nice.](https://i.imgur.com/Q8c3tg3.gif)
(The second string was printed by typing "And [\`d]Hell[\*4]oooooooooo[\*r] Dolly~[\`r]")

## Full Effect List
#### Last Updated: v1.6.0

**Color**
[\`0] - Black  
[\`1] - Dark Blue  
[\`2] - Dark Green  
[\`3] - Dark Turquoise  
[\`4] - Dark Red  
[\`5] - Purple  
[\`6] - Gold  
[\`7] - Gray  
[\`8] - Dark Gray  
[\`9] - Blue  
[\`a] - Green  
[\`b] - Aqua  
[\`c] - Red  
[\`d] - Light Purple  
[\`e] - Yellow  
[\`f] - White  
[\`r] - Resets the color back to default  
[\`#] - Forces a line break  

**Speed**  
[\*1] - Fastest  
[\*2] - Fast  
[\*3] - "Normal" (i think its p slow tbh)  
[\*4] - Slow  
[\*5] - Slowest  
[\*i] - Start instant print  
[\*n] - End instant and return to default speed   

**Position**  
[\^t] - Tipsy  
[\^d] - Drunk  
[\^v] - Vibrate  
[\^r] - Resets the effect back to default

**Pause**  
[s#] - Pause for # seconds  
[t#] - Pause for # tenths of a second  

**Hide**  
[|#] - Hide for # seconds  
[:#] - Hide for # tenths of a second  

**Font**  
Up to 10 alternate fonts can be configured in the inspector. To swap between them use the following tags  
[\*0] - Switch to the 1st alternative font  
[\*1] - Switch to the 2nd alternative font    
[\*2] - Switch to the 3rd alternative font    
...    
[\*9] - Switch to the 10th alternative font    
[\*r] - Reset the font back to default  

**Signal**  
The new signal tag allows you to embed an `identifer` in a Dialog string, which results in a custom signal being sent. This identifier can any single character that comes after the signal token `@`. For example `[@a]`, `[@1]`, `[@!]`. This gives you great flexibility in how your code interacts with your dialog letting you, for example, change the state of your world after you talk to someone, among many other possible scenarios. A very simple example of this in action is:  

- Given Dialog in a SyndiBox like this:  
`Time to test signals. [@b]`

- And code similar to this:  
```gdscript
$SyndiBox.connect('signal_tag', self, '_on_SyndiBox_signal_tag')

func _on_SyndiBox_signal_tag(identifier):
     if identifier == 'a':
         print('Path A')
     if identifier == 'b':
         print('Path B')
```
    
- Activating the SyndiBox would result in the following printed to the console:  
`Path B`  

## Custom Tags
SyndiBox allows you to create your own custom tags without overwriting the main addon code. The token for custom tages is `X`, for example `[X!]` or `[Xm]` or even `[X ]`. In order to do this you should do the following:  
- Find custom.gd in the addons folder  
- Add a new case to the match statement
- It is **critical** that you include `string.erase(sb.step,4)` and `string = string.insert(sb.step,char(8203) + "[:2][^r]")` if you do not wish to break encoding and nested tagging
- `sb` is the SyndiBox parent, and from there you can access any variables you wish to change, including but not limited to, `color`, `speed`, `font`, `timer`, and many more.

While the custom.gd has a couple good examples already, here is another simpler example:  
```gdscript
func check(string):
 match sb.emph:
  "[Xm]": # Example
   if !sb.escape:
    string.erase(sb.step,4)
    string = string.insert(sb.step,char(8203) + "[:2][^r]")
    sb.color = Color(255, 0, 255, 1)
```  
This very simple example turns the text magenta when you use the tag `[Xm]`.  
As custom tags are checked and processed last, you `X` tags will override all other tags. 

## Bugs/Issues
If you have any bugs/issues to report or features to request, please submit them to the Issues tab. If you need help and don't find your answer in the wiki's FAQ, Please contact me at Telegram (@sudospective) or Discord (Sudospective#0681) and I will reply at my earliest convenience.
