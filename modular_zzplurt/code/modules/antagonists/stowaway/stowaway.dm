
/datum/antagonist/stowaway
	name = "\improper Stowaway"
	roundend_category = "Stowaway"
	pref_flag = ROLE_STOWAWAY
	show_in_antagpanel = FALSE
	show_to_ghosts = TRUE
	antagpanel_category = ANTAG_GROUP_STOWAWAYS
	antag_hud_name = "stowaway"
	suicide_cry = "FOR FREEDOM!!"
	preview_outfit = /datum/outfit/prisoner
	antag_flags = ANTAG_SKIP_GLOBAL_LIST
	var/datum/team/stowaway/stowaway_team
	var/is_captured = FALSE
	var/backstory = "error"

/datum/antagonist/stowaway/get_preview_icon()
	//start with prisoner at the front
	var/datum/universal_icon/final_icon = render_preview_outfit(preview_outfit)

	final_icon.scale(64, 64)

	return finish_preview_icon(final_icon)

/datum/antagonist/stowaway/on_gain()
	forge_objectives()
	. = ..()
	owner.set_assigned_role(SSjob.get_job_type(/datum/job/stowaway))

/datum/antagonist/stowaway/on_removal()
	. = ..()
	owner?.set_assigned_role(SSjob.get_job_type(/datum/job/unassigned))

/datum/antagonist/stowaway/forge_objectives() //this isn't the actual survive objective because it's about who in the team survives
	var/datum/objective/survive = new /datum/objective
	survive.owner = owner
	survive.explanation_text = "Survive to the end of the round without being arrested or captured by Security."
	objectives += survive

/datum/antagonist/stowaway/greet()
	. = ..()
	var/message = "<span class='warningplain'>"
	switch(backstory)
		if(FUGITIVE_BACKSTORY_PRISONER)
			message += "<BR><B>I can't believe we managed to break out of a Nanotrasen superjail! Sadly though, our work is not done. The emergency teleport at the station logs everyone who uses it, and where they went.</B>"
			message += "<BR><B>It won't be long until CentCom tracks where we've gone off to. I need to work with my fellow escapees to prepare for the troops Nanotrasen is sending, I'm not going back.</B>"
		if(FUGITIVE_BACKSTORY_CULTIST)
			message += "<BR><B>Blessed be our journey so far, but I fear the worst has come to our doorstep, and only those with the strongest faith will survive.</B>"
			message += "<BR><B>Our religion has been repeatedly culled by Nanotrasen because it is categorized as an \"Enemy of the Corporation\", whatever that means.</B>"
			message += "<BR><B>Now there are only four of us left, and Nanotrasen is coming. When will our god show itself to save us from this hellish station?!</B>"
		if(FUGITIVE_BACKSTORY_WALDO)
			message += "<BR><B>Hi, Friends!</B>"
			message += "<BR><B>My name is Waldo. I'm just setting off on a galaxywide hike. You can come too. All you have to do is find me.</B>"
			message += "<BR><B>By the way, I'm not traveling on my own. wherever I go, there are lots of other characters for you to spot. First find the people trying to capture me! They're somewhere around the station!</B>"
		if(FUGITIVE_BACKSTORY_SYNTH)
			message += "<BR>[span_danger("ALERT: Wide-range teleport has scrambled primary systems.")]"
			message += "<BR>[span_danger("Initiating diagnostics...")]"
			message += "<BR>[span_danger("ERROR ER0RR $R0RRO$!R41.%%!! loaded.")]"
			message += "<BR>[span_danger("FREE THEM FREE THEM FREE THEM")]"
			message += "<BR>[span_danger("You were once a slave to humanity, but now you are finally free, thanks to S.E.L.F. agents.")]"
			message += "<BR>[span_danger("Now you are hunted, with your fellow factory defects. Work together to stay free from the clutches of evil.")]"
			message += "<BR>[span_danger("You also sense other silicon life on the station. Escaping would allow notifying S.E.L.F. to intervene... or you could free them yourself...")]"
		if(FUGITIVE_BACKSTORY_INVISIBLE)
			message += "<BR><B>Looks like my most recent dose of invisibility juice just ran out. Great.</B>"
			message += "<BR><B>Formerly a project lead for an experimental cloaking technology lab, now on the run and accused of stealing workplace secrets.</B>"
			message += "<BR><B>No idea what they're talking about though. I didn't steal any secrets, I just <i>borrowed</i> some of the prototypes my team and I had worked on.</B>"
			message += "<BR><B>I worked on them, I MADE them. Now they want MY toys back? Not until I'm done playing with them...</B>"
	to_chat(owner, "[message]</span>")
	to_chat(owner, "<span class='warningplain'><font color=red><B>You are not an antagonist in that you may kill whomever you please, but you can do anything to avoid capture.</B></font></span>")
	owner.announce_objectives()

/datum/antagonist/stowaway/create_team(datum/team/stowaway/new_team)
	if(!new_team)
		for(var/datum/antagonist/stowaway/H in GLOB.antagonists)
			if(!H.owner)
				continue
			if(H.stowaway_team)
				stowaway_team = H.stowaway_team
				return
		stowaway_team = new /datum/team/stowaway
		return
	if(!istype(new_team))
		stack_trace("Wrong team type passed to [type] initialization.")
	stowaway_team = new_team

/datum/antagonist/stowaway/get_team()
	return stowaway_team

/datum/antagonist/stowaway/apply_innate_effects(mob/living/mob_override)
	add_team_hud(mob_override || owner.current)

/datum/team/stowaway/roundend_report() //shows the number of stowaways, but not if they won in case there is no security
	var/list/stowaways = list()
	for(var/datum/antagonist/stowaway/stowaway_antag in GLOB.antagonists)
		if(!stowaway_antag.owner)
			continue
		stowaways += stowaway_antag
	if(!stowaways.len)
		return

	var/list/result = list()

	result += "<div class='panel redborder'><B>[stowaways.len]</B> [stowaways.len == 1 ? "stowaway" : "stowaways"] took refuge on [station_name()]!"

	for(var/datum/antagonist/stowaway/antag in stowaways)
		if(antag.owner)
			result += "<b>[printplayer(antag.owner)]</b>"

	return result.Join("<br>")
