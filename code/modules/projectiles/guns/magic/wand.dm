/obj/item/gun/magic/wand
	name = "wand of nothing"
	desc = "It's not just a stick, it's a MAGIC stick!"
	ammo_type = /obj/item/ammo_casing/magic
	icon_state = "nothingwand"
	item_state = "wand"
	w_class = WEIGHT_CLASS_SMALL
	weapon_weight = WEAPON_LIGHT
	can_charge = FALSE
	max_charges = 100 //100, 50, 50, 34 (max charge distribution by 25%ths)
	var/variable_charges = TRUE

/obj/item/gun/magic/wand/Initialize(mapload)
	if(prob(75) && variable_charges) //25% chance of listed max charges, 50% chance of 1/2 max charges, 25% chance of 1/3 max charges
		if(prob(33))
			max_charges = CEILING(max_charges / 3, 1)
		else
			max_charges = CEILING(max_charges / 2, 1)
	return ..()

/obj/item/gun/magic/wand/examine(mob/user)
	. = ..()
	. += "Has [charges] charge\s remaining."

/obj/item/gun/magic/wand/update_icon()
	icon_state = "[initial(icon_state)][charges ? "" : "-drained"]"

/obj/item/gun/magic/wand/attack(atom/target, mob/living/user)
	if(target == user)
		return
	..()

/obj/item/gun/magic/wand/afterattack(atom/target, mob/living/user)
	if(!charges)
		shoot_with_empty_chamber(user)
		return
	if(target == user)
		if(no_den_usage)
			var/area/A = get_area(user)
			if(istype(A, /area/wizard_station))
				to_chat(user, span_warning("You know better than to violate the security of The Den, best wait until you leave to use [src]."))
				return
			else
				no_den_usage = 0
		zap_self(user)
	else
		. = ..()
	update_icon()


/obj/item/gun/magic/wand/proc/zap_self(mob/living/user)
	user.visible_message(span_danger("[user] zaps [user.p_them()]self with [src]."))
	playsound(user, fire_sound, 50, 1)
	user.log_message("zapped [user.p_them()]self with a <b>[src]</b>", LOG_ATTACK)


/////////////////////////////////////
//WAND OF DEATH
/////////////////////////////////////

/obj/item/gun/magic/wand/death
	name = "wand of death"
	desc = "This deadly wand overwhelms the victim's body with pure energy, slaying them without fail."
	fire_sound = 'sound/magic/wandodeath.ogg'
	ammo_type = /obj/item/ammo_casing/magic/death
	icon_state = "deathwand"
	max_charges = 3 //3, 2, 2, 1

/obj/item/gun/magic/wand/death/zap_self(mob/living/user)
	..()
	to_chat(user, span_warning("You irradiate yourself with pure energy! \
	[pick("Do not pass go. Do not collect 200 zorkmids.","You feel more confident in your spell casting skills.","You Die...","Do you want your possessions identified?")]"))
	user.adjustOxyLoss(500)
	charges--

/obj/item/gun/magic/wand/death/debug
	desc = "In some obscure circles, this is known as the 'cloning tester's friend'."
	max_charges = 500
	variable_charges = FALSE
	can_charge = TRUE
	recharge_rate = 1


/////////////////////////////////////
//WAND OF HEALING
/////////////////////////////////////

/obj/item/gun/magic/wand/resurrection
	name = "wand of healing"
	desc = "This wand uses healing magics to heal and revive. They are rarely utilized within the Wizard Federation for some reason."
	ammo_type = /obj/item/ammo_casing/magic/heal
	fire_sound = 'sound/magic/staff_healing.ogg'
	icon_state = "revivewand"
	max_charges = 10 //10, 5, 5, 4

/obj/item/gun/magic/wand/resurrection/zap_self(mob/living/user)
	user.revive(full_heal = 1)
	if(iscarbon(user))
		var/mob/living/carbon/C = user
		C.regenerate_limbs()
		C.regenerate_organs()
	to_chat(user, span_notice("You feel great!"))
	charges--
	..()

/obj/item/gun/magic/wand/resurrection/debug //for testing
	desc = "Is it possible for something to be even more powerful than regular magic? This wand is."
	max_charges = 500
	variable_charges = FALSE
	can_charge = TRUE
	recharge_rate = 1

/obj/item/gun/magic/wand/resurrection/inert
	name = "weakened wand of healing"
	desc = "This wand uses healing magics to heal and revive. The years of the cold have weakened the magic inside the wand."
	max_charges = 5

/////////////////////////////////////
//WAND OF POLYMORPH
/////////////////////////////////////

/obj/item/gun/magic/wand/polymorph
	name = "wand of polymorph"
	desc = "This wand is attuned to chaos and will radically alter the victim's form."
	ammo_type = /obj/item/ammo_casing/magic/change
	icon_state = "polywand"
	fire_sound = 'sound/magic/staff_change.ogg'
	max_charges = 10 //10, 5, 5, 4

/obj/item/gun/magic/wand/polymorph/zap_self(mob/living/user)
	. = ..() //because the user mob ceases to exists by the time wabbajack fully resolves
	user.wabbajack()
	charges--

/////////////////////////////////////
//WAND OF TELEPORTATION
/////////////////////////////////////

/obj/item/gun/magic/wand/teleport
	name = "wand of teleportation"
	desc = "This wand will wrench targets through space and time to move them somewhere else."
	ammo_type = /obj/item/ammo_casing/magic/teleport
	fire_sound = 'sound/magic/wand_teleport.ogg'
	icon_state = "telewand"
	max_charges = 10 //10, 5, 5, 4
	no_den_usage = TRUE

/obj/item/gun/magic/wand/teleport/zap_self(mob/living/user)
	if(do_teleport(user, user, 10, channel = TELEPORT_CHANNEL_MAGIC, teleport_mode = TELEPORT_ALLOW_WIZARD))
		var/datum/effect_system/smoke_spread/smoke = new
		smoke.set_up(3, user.loc)
		smoke.start()
		charges--
	..()

/obj/item/gun/magic/wand/safety
	name = "wand of safety"
	desc = "This wand will use the lightest of bluespace currents to gently place the target somewhere safe."
	ammo_type = /obj/item/ammo_casing/magic/safety
	fire_sound = 'sound/magic/wand_teleport.ogg'
	icon_state = "telewand"
	max_charges = 10 //10, 5, 5, 4
	no_den_usage = FALSE

/obj/item/gun/magic/wand/safety/zap_self(mob/living/user)
	var/turf/origin = get_turf(user)
	var/turf/destination = find_safe_turf()

	if(do_teleport(user, destination, channel=TELEPORT_CHANNEL_MAGIC, teleport_mode = TELEPORT_ALLOW_WIZARD))
		for(var/t in list(origin, destination))
			var/datum/effect_system/smoke_spread/smoke = new
			smoke.set_up(0, t)
			smoke.start()
	..()

/obj/item/gun/magic/wand/safety/debug
	desc = "This wand has 'find_safe_turf()' engraved into its blue wood. Perhaps it's a secret message?"
	max_charges = 500
	variable_charges = FALSE
	can_charge = TRUE
	recharge_rate = 1


/////////////////////////////////////
//WAND OF DOOR CREATION
/////////////////////////////////////

/obj/item/gun/magic/wand/door
	name = "wand of door creation"
	desc = "This particular wand can create doors in any wall for the unscrupulous wizard who shuns teleportation magics."
	ammo_type = /obj/item/ammo_casing/magic/door
	icon_state = "doorwand"
	fire_sound = 'sound/magic/staff_door.ogg'
	max_charges = 20 //20, 10, 10, 7
	no_den_usage = 1

/obj/item/gun/magic/wand/door/zap_self(mob/living/user)
	to_chat(user, span_notice("You feel vaguely more open with your feelings."))
	charges--
	..()

/////////////////////////////////////
//WAND OF FIREBALL
/////////////////////////////////////

/obj/item/gun/magic/wand/fireball
	name = "wand of fireball"
	desc = "This wand shoots scorching balls of fire that explode into destructive flames."
	fire_sound = 'sound/magic/fireball.ogg'
	ammo_type = /obj/item/ammo_casing/magic/fireball
	icon_state = "firewand"
	max_charges = 8 //8, 4, 4, 3

/obj/item/gun/magic/wand/fireball/zap_self(mob/living/user)
	..()
	explosion(user.loc, -1, 0, 2, 3, 0, flame_range = 2, magic = TRUE)
	charges--

/obj/item/gun/magic/wand/fireball/inert
	name = "weakened wand of fireball"
	desc = "This wand shoots scorching balls of fire that explode into destructive flames. The years of the cold have weakened the magic inside the wand."
	max_charges = 4

