## Lurch, an Autumn Leaf
### Copyright 2009 (ZepFrog Corp.), by Mark Coates and Noah Sussman

![Image of Lurch](https://media.giphy.com/media/zUJbUzNeMhelW/giphy.gif) 

Lurch is an IRC bot that makes it easy to log time spent on tasks and the interruptions to said tasks using the Slim Timer API and the [Autumn IRC Bot Framework](http://github.com/oddlyzen/autumn/tree/master). The name has a double-meaning, of course, as it references the Addams' Family character and the on-and-off pace of a workday filled with distractions.

Lurch was the Addams-family butler, but they treated him as part of the clan. He was fast--often demonstrating a prescience that was uncanny and entertaining, answering with his ever-faithful, "You *rang*?"  Lurch is meant to be your personal time-butler in your favorite IRC channel.  Ours is #zepinvest (chat.us.freenode.net).

The second meaning for Lurch comes from a Web search:
  * stagger: walk as if unable to control one's movements; "The drunken man staggered into the room"
  * move abruptly; "The ship suddenly lurched to the left"
  * an unsteady uneven gait
  * prowl: loiter about, with no apparent aim
  * the act of moving forward suddenly (http://wordnet.princeton.edu/perl/webwn)

That's how our workflow sometimes goes. We start coding, and suddenly someone walks up on us and clears their throat.  Interrupt! And then we lose the flow and everything generally goes to shit. To prove that point to disbelievers (mainly the people who interrupt us), we wanted a way to easily:
  * Keep track of the task I am currently working on
  * Track the amount of time I spend on the task
  * Tag my tasks for filtering
  * Allow for multiple tasks to be stacked (multiple tasks on one clock)
  * Allow for quick interruptions--and to track *that* time, too.

Lurch all that.  All you need to do is get a free Slim Timer account (http://slimtimer.com). Once you login, you will see a tab named 'API'. Click on that and get yourself an API key.  It's fast. It's free. It's legal. It's fun.  Then you just need to add a `config.yml` to Lurch's root directory.  It's contents should be something like:

```ruby 
st_password: password
st_user: user@your.com
st_api_key: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

about_msg: 'You *rang*?'
```

For more information, see the [Documentation](http://github.com/oddlyzen/lurch/tree/master).
