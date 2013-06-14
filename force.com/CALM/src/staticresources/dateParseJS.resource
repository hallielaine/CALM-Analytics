function parseDates(start, end)
{
    if (validDates(start, end))
    {
        return [new Date(start), new Date(end)];
    }
    return [];
}

function shouldParse(start, end)
{
    if (start == '' || end == '')
    {
        return false;
    }
    return true;
}

function validDates(start, end)
{
    if (Date.parse(end) - Date.parse(start) >= 0)
        return true;
    return false;
}

function canDisplay(date)
{
	return date != null && date != '';
}