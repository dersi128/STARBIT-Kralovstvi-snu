extends "res://tests/chapter_rework.gd"

func run() -> void:
	output=OS.get_environment("STARBIT_TEST_OUTPUT")
	if output.is_empty():quit(2);return
	root.get_node("Progress").save_path=output.path_join("isolated-routes.cfg")
	root.get_node("Progress").muted=true
	game=load("res://Main.tscn").instantiate();root.add_child(game)
	await frames(3)
	for n in range(1,11):
		await game.start_level(n)
		await frames(12)
		var level=game.level
		for actor in get_nodes_in_group("enemies"):
			if level.is_ancestor_of(actor):actor.process_mode=Node.PROCESS_MODE_DISABLED
		if level.has_node("Boss"):
			level.get_node("Boss").defeated=true
			level.get_node("Boss").process_mode=Node.PROCESS_MODE_DISABLED
			level.boss_alive=false
		var route:Array[Node2D]=[]
		for platform in get_nodes_in_group("chapter_route"):
			if level.is_ancestor_of(platform):route.append(platform)
		for i in range(route.size()-1):
			if n==8 and i>=4:level.player.has_fouk=false
			await jump_between(route[i],route[i+1],"main %d"%n)
		# Validate the two jumps to the hidden entrance with actual movement input.
		var step=level.get_node("SecretStep")
		var landing=level.get_node("SecretLanding")
		var support:Node2D
		for platform in level.get_children():
			if platform is PhysicsBody2D and platform.get("width")!=null and platform.position.x<=step.position.x and platform.position.x+platform.width>=step.position.x+step.width and platform.position.y>step.position.y:
				if support==null or platform.position.y<support.position.y:support=platform
		check(support!=null,"No ground below secret step %d"%n)
		if support!=null:
			await jump_between(support,step,"secret %d"%n,true)
			await jump_between(step,landing,"secret %d"%n)
		var room=level.get_node("BonusRoom")
		room.enter_room(level.get_node("SecretEntrance").global_position)
		await frames(10)
		var bonus:Array[Node2D]=[]
		for platform in room.get_children():
			if platform.name.begins_with("BonusPlatform"):bonus.append(platform)
		for i in range(bonus.size()-1):await jump_between(bonus[i],bonus[i+1],"bonus %d"%n)
		room.leave_room()
		print("ROUTE ",n," checked")
	print("JUMP CHECKS=",checks," FAILURES=",failures)
	quit(1 if failures else 0)

func jump_between(source:Node2D,target:Node2D,label:String,vertical:bool=false) -> void:
	var player=game.level.player
	var reached:=false
	for attempt in 3:
		game.release_input()
		player.cancel_interaction()
		player.frozen=false
		player.invulnerable=999.0
		player.velocity=Vector2.ZERO
		if source.get("countdown")!=null:
			source.countdown=-1.0;source.absent=false;source.get_node("CollisionShape2D").disabled=false
		var takeoff:float=source.global_position.x+source.width-35
		if vertical:takeoff=target.global_position.x+target.width*.5-65
		player.global_position=Vector2(takeoff-90,source.global_position.y-4)
		await frames(6)
		Input.action_press("right")
		for tick in 30:
			if player.global_position.x>=takeoff:break
			await frames(1)
		Input.action_press("jump")
		var boosted:=false
		var use_boost:bool=player.has_fouk and (target.global_position.x-takeoff>260 or source.global_position.y-target.global_position.y>110)
		var goal_x:float=target.global_position.x+minf(85,target.width*.5)
		for tick in 130:
			if player.global_position.x>=goal_x-9:
				Input.action_release("right")
			if use_boost and tick==21:Input.action_release("jump")
			if use_boost and tick==24:
				Input.action_press("jump");boosted=true
			await frames(1)
			if tick>7 and player.is_on_floor():
				for collision in player.get_slide_collision_count():
					if player.get_slide_collision(collision).get_collider()==target:reached=true
				if reached:break
			if player.global_position.y>maxf(source.global_position.y,target.global_position.y)+180:break
		game.release_input()
		if reached:break
		await frames(30+attempt*15)
	check(reached,"Unreachable %s %s -> %s (ended %s)"%[label,source.name,target.name,player.global_position])
