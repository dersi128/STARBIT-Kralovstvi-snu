extends SceneTree
var fails:=0
func check(ok:bool,label:String):
 print("PASS " if ok else "FAIL ",label)
 if not ok:fails+=1
func frames(n:int):
 for i in n:await process_frame
func _initialize():call_deferred("run")
func run():
 var game=load("res://Main.tscn").instantiate();root.add_child(game)
 var audio=root.get_node("Progress");audio.muted=false
 await frames(2)
 game.start_level(1);await frames(50)
 check(audio.music_track=="adventure" and audio.music.playing,"adventure soundtrack")
 check(audio.music.stream.get_length()>60,"long music phrase")
 game.pause_game();await frames(3)
 check(audio.music.stream_paused,"pause stops music")
 game.menu();await frames(3)
 check(audio.music.stream_paused,"menu keeps music paused")
 game.resume();await frames(3)
 check(not audio.music.stream_paused,"resume restores music")
 game.start_level(5);await frames(3)
 var boss=get_first_node_in_group("boss")
 boss.state="warn";boss.timer=1.19
 await frames(5)
 check(boss.state=="charge","boss push triggered")
 check(audio.music_track=="boss","boss music transition")
 var found:=false
 for tone in audio.tones:
  if tone.stream is AudioStreamOggVorbis:found=true
 check(found,"push plays bear sound")
 audio.muted=true;await frames(2)
 check(audio.music.stream_paused and audio.tones.is_empty(),"mute covers music and effects")
 audio.muted=false;await frames(3)
 check(not audio.music.stream_paused,"unmute resumes")
 boss.defeated=true;boss.state="defeated";await frames(3)
 check(audio.music_track=="victory" and not audio.music.stream.loop,"victory motif once")
 game.pause_game();await frames(50)
 check(audio.fading_music.is_empty(),"crossfade voices cleaned")
 print("AUDIO FAILURES ",fails)
 audio.silence()
 if is_instance_valid(audio.music):audio.music.stop();audio.music.queue_free()
 game.queue_free();await frames(3)
 quit(fails)
