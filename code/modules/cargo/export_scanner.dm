/obj/item/export_scanner
	name = "export scanner"
	desc = "A device used to check objects against Nanotrasen exports and bounty database."
	icon = 'icons/obj/device.dmi'
	icon_state = "export_scanner"
	item_state = "radio"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	item_flags = NOBLUDGEON
	w_class = WEIGHT_CLASS_SMALL
	siemens_coefficient = 1
	var/obj/machinery/computer/cargo/cargo_console = null

/obj/item/export_scanner/examine(user)
	. = ..()
	if(!cargo_console)
		. += span_notice("[src] is not currently linked to a cargo console.")

/obj/item/export_scanner/afterattack(obj/O, mob/user, proximity)
	. = ..()
	if(!istype(O) || !proximity || HAS_TRAIT(O, TRAIT_IGNORE_EXPORT_SCAN))
		if(HAS_TRAIT(O, TRAIT_IGNORE_EXPORT_SCAN))
			to_chat(user, "<span class='warning'>[O] cannot be scanned!</span>")
		return

	if(istype(O, /obj/machinery/computer/cargo))
		var/obj/machinery/computer/cargo/C = O
		if(!C.requestonly)
			cargo_console = C
			to_chat(user, span_notice("Scanner linked to [C]."))
	else if(!istype(cargo_console))
		to_chat(user, span_warning("You must link [src] to a cargo console first!"))
	else
		// Before you fix it:
		// yes, checking manifests is a part of intended functionality.

		var/datum/export_report/ex = export_item_and_contents(O, cargo_console.get_export_categories(), dry_run=TRUE)
		var/price = 0
		for(var/x in ex.total_amount)
			price += ex.total_value[x]

		if(price)
			to_chat(user, span_notice("Scanned [O], value: <b>[price]</b> credits[O.contents.len ? " (contents included)" : ""]."))
		else
			to_chat(user, span_warning("Scanned [O], no export value."))
		if(bounty_ship_item_and_contents(O, dry_run=TRUE))
			to_chat(user, span_notice("Scanned item is eligible for one or more bounties."))
