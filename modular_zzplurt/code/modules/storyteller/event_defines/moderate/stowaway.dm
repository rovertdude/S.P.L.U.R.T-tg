### Stowaways Event
### this event prompts ghosts to become a stowaway on the station, with a few varieties

/datum/round_event_control/stowaways
	name = "Spawn Stowaway"
	typepath = /datum/round_event/ghost_role/stowaway
	track = EVENT_TRACK_MODERATE
	tags = list(TAG_LOW)
	max_occurrences = 2
	min_players = 1
	earliest_start = 0 MINUTES
	category = EVENT_CATEGORY_INVASION
	description = "A Stowaway will spawn on the station."

/datum/round_event/ghost_role/stowaway
	minimum_required = 1
	role_name = "stowaway"
	fakeable = FALSE

/datum/round_event/ghost_role/stowaways/spawn_role()
	var/turf/landing_turf = find_maintenance_spawn(atmos_sensitive = TRUE, require_darkness = FALSE)
	if(isnull(landing_turf))
		return MAP_ERROR
	var/list/possible_backstories = list()
	// TODO: Edit the job ban for this ghost role
	var/list/candidates = SSpolling.poll_ghost_candidates(check_jobban = ROLE_FUGITIVE, role = ROLE_FUGITIVE, alert_pic = /obj/item/card/id/advanced/prisoner, jump_target = landing_turf)

	if(!length(candidates))
		return NOT_ENOUGH_PLAYERS

	## Stealing this temporarily from fugitives while I poke at this event concept
	if(length(candidates) < TEAM_BACKSTORY_SIZE || prob(30 - (length(candidates) * 2))) //Solo backstories are always considered if a larger backstory cannot be filled out. Otherwise, it's a rare chance that gets rarer if more people sign up.
		possible_backstories += list(FUGITIVE_BACKSTORY_WALDO, FUGITIVE_BACKSTORY_INVISIBLE) //less common as it comes with magicks and is kind of immershun shattering

	if(length(candidates) >= TEAM_BACKSTORY_SIZE)//group refugees
		possible_backstories += list(FUGITIVE_BACKSTORY_PRISONER, FUGITIVE_BACKSTORY_CULTIST, FUGITIVE_BACKSTORY_SYNTH)

	var/backstory = pick(possible_backstories)
	var/member_size = 3
	var/leader
	switch(backstory)
		if(FUGITIVE_BACKSTORY_SYNTH)
			leader = pick_n_take(candidates)
		if(FUGITIVE_BACKSTORY_WALDO, FUGITIVE_BACKSTORY_INVISIBLE)
			member_size = 0 //solo refugees have no leader so the member_size gets bumped to one a bit later
	var/list/members = list()
	var/list/spawned_mobs = list()
	if(isnull(leader))
		member_size++ //if there is no leader role, then the would be leader is a normal member of the team.

	for(var/i in 1 to member_size)
		members += pick_n_take(candidates)

	for(var/mob/dead/selected in members)
		var/mob/living/carbon/human/S = gear_stowaway(selected, landing_turf, backstory)
		spawned_mobs += S
	if(!isnull(leader))
		gear_stowaway_leader(leader, landing_turf, backstory)

	//after spawning
	playsound(src, 'sound/items/weapons/emitter.ogg', 50, TRUE)
	new /obj/item/storage/toolbox/mechanical(landing_turf) //so they can actually escape maint
	return SUCCESSFUL_SPAWN

/datum/round_event/ghost_role/stowaways/proc/gear_stowaway(mob/dead/selected, turf/landing_turf, backstory) //spawns a stowaway
	var/datum/mind/player_mind = new /datum/mind(selected.key)
	player_mind.active = TRUE
	var/mob/living/carbon/human/S = new(landing_turf)
	player_mind.transfer_to(S)
	player_mind.set_assigned_role(SSjob.get_job_type(/datum/job/stowaway))
	player_mind.add_antag_datum(/datum/antagonist/stowaway)
	var/datum/antagonist/stowaway/stowawayantag = player_mind.has_antag_datum(/datum/antagonist/stowaway)
	stowawayantag.greet(backstory)

	switch(backstory)
		/// TODO: the types of fugitives outfits can go here
		if(FUGITIVE_BACKSTORY_PRISONER)
			S.equipOutfit(/datum/outfit/prisoner)
		if(FUGITIVE_BACKSTORY_CULTIST)
			S.equipOutfit(/datum/outfit/yalp_cultist)
		if(FUGITIVE_BACKSTORY_WALDO)
			S.equipOutfit(/datum/outfit/waldo)
		if(FUGITIVE_BACKSTORY_SYNTH)
			S.equipOutfit(/datum/outfit/synthetic)
		if(FUGITIVE_BACKSTORY_INVISIBLE)
			S.equipOutfit(/datum/outfit/invisible_man)
	message_admins("[ADMIN_LOOKUPFLW(S)] has been made into a Stowaway by an event.")
	S.log_message("was spawned as a Stowaway by an event.", LOG_GAME)
	spawned_mobs += S
	return S

///special spawn for one member. it can be used for a special mob or simply to give one normal member special items.
/datum/round_event/ghost_role/stowaways/proc/gear_stowaway_leader(mob/dead/leader, turf/landing_turf, backstory)
	var/datum/mind/player_mind = new /datum/mind(leader.key)
	player_mind.active = TRUE
	//if you want to add a stowaway with a special leader in the future, make this switch with the backstory
	var/mob/living/carbon/human/S = gear_stowaway(leader, landing_turf, backstory)
	var/obj/item/choice_beacon/augments/A = new(landing_turf)
	S.put_in_hands(A)
	new /obj/item/autosurgeon(landing_turf)
