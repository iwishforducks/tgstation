/datum/job/security_witch
	title = JOB_SECURITY_WITCH
	description = "Curse the no-good assistants among the station."
	auto_deadmin_role_flags = DEADMIN_POSITION_HEAD|DEADMIN_POSITION_SECURITY
	department_head = list(JOB_HEAD_OF_SECURITY)
	faction = FACTION_STATION
	total_positions = 1
	spawn_positions = 1
	supervisors = SUPERVISOR_CAPTAIN
	minimal_player_age = 7
	exp_requirements = 300
	exp_required_type = EXP_TYPE_CREW
	exp_granted_type = EXP_TYPE_CREW
	config_tag = "SECURIY_WITCH"

	outfit = /datum/outfit/job/security_witch
	plasmaman_outfit = /datum/outfit/plasmaman/security

	paycheck = PAYCHECK_CREW
	paycheck_department = ACCOUNT_SEC

	liver_traits = list(TRAIT_LAW_ENFORCEMENT_METABOLISM, TRAIT_PRETENDER_ROYAL_METABOLISM)

	display_order = JOB_DISPLAY_ORDER_SECURITY_WITCH
	bounty_types = CIV_JOB_SEC
	departments_list = list(
		/datum/job_department/security,
		)

	family_heirlooms = list(/obj/item/book/manual/wiki/security_space_law)

	mail_goodies = list(
		/obj/item/mop = 15
	)
	rpg_title = "Witch"
	job_flags = STATION_JOB_FLAGS | JOB_BOLD_SELECT_TEXT

/datum/outfit/job/security_witch
	name = "Security Witch"
	jobtype = /datum/job/security_witch

	id_trim = /datum/id_trim/job/security_witch
	uniform = /obj/item/clothing/under/color/lightpurple
	suit = /obj/item/clothing/suit/wizrobe/marisa
	backpack_contents = list(
		/obj/item/grenade/chem_grenade/hex/slow = 1,
		/obj/item/grenade/chem_grenade/hex/grease = 1,
		/obj/item/grenade/smokebomb/hex = 1,
		/obj/item/grenade/chem_grenade/hex/fireball = 1,
		/obj/item/grenade/chem_grenade/hex/yarn = 1,
		/obj/item/witch_broom_beacon = 1,
		/obj/item/key/witch = 1,
	)
	belt = /obj/item/gun/energy/taser/witch
	ears = /obj/item/radio/headset/headset_sec/alt
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses
	head = /obj/item/clothing/head/costume/witchwig
	shoes = /obj/item/clothing/shoes/sneakers/marisa
	l_pocket = /obj/item/restraints/handcuffs
	r_pocket = /obj/item/modular_computer/pda/security

	backpack = /obj/item/storage/backpack/security
	satchel = /obj/item/storage/backpack/satchel/sec
	duffelbag = /obj/item/storage/backpack/duffelbag/sec

	box = /obj/item/storage/box/survival/security
	implants = list(/obj/item/implant/mindshield)

/datum/job/security_witch/after_spawn(mob/living/spawning, client/player_client)
	. = ..()

/datum/job/security_witch/after_roundstart_spawn(mob/living/spawning, client/player_client)
	. = ..()
	if(ishuman(spawning))
		var/spawnpoint = pick(GLOB.jobspawn_overrides["security_officer"])
		spawning.Move(get_turf(spawnpoint))

/datum/outfit/job/security_witch/post_equip(mob/living/carbon/human/spawning, visualsOnly = FALSE)
	. = ..()
	var/datum/action/innate/witchlaugh/laughaction = new()
	laughaction.Grant(spawning)

	for(var/obj/item/bodypart/part as anything in spawning.bodyparts)
		part.variable_color = "#009e00"
	spawning.update_body_parts()

/datum/action/innate/witchlaugh
	name = "Witch Laugh"
	desc = "Cackle a sinister witch laugh and strike fear into any nearby assistants!"
	check_flags = AB_CHECK_CONSCIOUS
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "terrify"
	var/cooldown = 20 SECONDS
	var/last_use
	var/spooked_assistants = 0
	var/hex_per_spooked = 5
	var/list/hex_grenades = list(
		/obj/item/grenade/chem_grenade/hex/slow = 1,
		/obj/item/grenade/chem_grenade/hex/grease = 1,
		/obj/item/grenade/smokebomb/hex = 1,
		/obj/item/grenade/chem_grenade/hex/fireball = 1,
		/obj/item/grenade/chem_grenade/hex/yarn = 1
	)

/datum/action/innate/witchlaugh/Activate()
	if(world.time < last_use + cooldown)
		to_chat(owner, "<span class='warning'>You aren't ready yet to cackle again!</span>")
		return
	owner.visible_message("<span class='warning'>[owner] cackles a sinister laughter!</span>", "<span class='notice'>You cackle a sinister laughter!</span>")
	last_use = world.time
	owner.manual_emote("cackles!")
	playsound(get_turf(owner),'sound/magic/witchlaugh.ogg', 8, TRUE)
	for(var/mob/living/target in orange(7, get_turf(owner)))
		if((target.mind && is_assistant_job(target.mind.assigned_role)))
			to_chat(target, "<span class='cultlarge'>The sound of the Security Witch cackling spooks you to your core!</span>")
			target.emote("scream")
			target.say("AAAAH!!")
			target.set_jitter_if_lower(30 SECONDS)
			target.add_mood_event("witchspooked", /datum/mood_event/witchspooked)
			spooked_assistants++
			if(spooked_assistants >= hex_per_spooked)
				var/obj/pickedGrenade = pick(hex_grenades)
				new pickedGrenade(get_turf(owner))
				spooked_assistants = spooked_assistants - hex_per_spooked
				owner.balloon_alert(owner, "hex created!")
				to_chat(owner, "You've scared enough assistants to create another hex!")
