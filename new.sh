#/bin/sh

function isWeekday {
	date | egrep -q 'Mon|Tue|Wed|Thu|Fri'
	return $?
}

function isWeekend {
	date | egrep -q 'Sat|Sun'
	return $?
}

function isNinja {
	date | egrep -q 'Mon|Wed'
	return $?
}

function isThur {
	date | grep -q 'Thu'
	return $?
}

task add 'Medicin' due:06:30 tag:personal
if isWeekday; then
	task add 'Maya morgenmad' due:07:30 tag:weekday
	task add 'Maya frokost og snacks' due:07:30 tag:weekday
	task add 'Lisbet frokost' due:07:30 tag:weekday
fi
task add 'Morgenmad' due:08:00 tag:daily
task add 'Børste tænder (morgen)' due:08:00 tag:daily
task add 'Gå med Molly (morgen)' due:09:00 tag:dog
task add 'Fodre Molly (morgen)' due:10:00 tag:dog
task add 'Gå med Molly (eftermiddag)' due:18:00 tag:dog
task add 'Fodre Molly (aften)' due:19:00 tag:dog
if isThur; then
	task add 'Hundetræning' due:22:00 tag:dog
else
	task add 'Gå med Molly (aften)' due:21:00 tag:dog
fi
task add 'Børste tænder (aften)' due:22:00 tag:personal
task add 'Gå i bad' due:22:00 tag:personal

if isNinja; then
	task add 'Maya TKD' due:19:00 tag:ninja
	task add 'Støvsuge' due:12:00 tag:hoover
fi

