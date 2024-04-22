import PostgresInterval from "postgres-interval";

export default class Interval extends PostgresInterval
{
	static format = "^([0123456789]+y)?([0123456789]+d)?([0123456789]+h)?([0123456789]+m)?([0123456789]+s)?$";
	static #format = new RegExp(Interval.format);
    constructor(input = 0)
    {
        switch (typeof input)
        {
            case "number":
            {
                super();
                this.seconds = input;
                break;
            }
            case "object":
            {
                super();
                if (!isNaN(input.years)) this.years += Number(input.years);
                if (!isNaN(input.months)) this.months += Number(input.months);
                if (!isNaN(input.days)) this.days += Number(input.days);
                if (!isNaN(input.hours)) this.hours += Number(input.hours);
                if (!isNaN(input.minutes)) this.minutes += Number(input.minutes);
                if (!isNaN(input.seconds)) this.seconds += Number(input.seconds);
                if (!isNaN(input.milliseconds)) this.milliseconds += Number(input.milliseconds);
                break;
            }
            case "string":
            {
                if (Interval.#format.test(input))
                {
                    super();
                    while (input.length != 0)
                    {
                        const index = input.search(/y|d|h|m|s/), number = Number(input.slice(0, index));
                        switch(input[index])
                        {
                            case "y": { this.years += number; break; }
                            case "d": { this.days += number; break; }
                            case "h": { this.hours += number; break; }
                            case "m": { this.minutes += number; break; }
                            case "s": { this.seconds += number; break; }
                            default: { }
                        }
                        input = input.slice(index + 1);
                    }
                    break;
                }
            }
            default: { super(input); }
        }
        this.normalize();
    }

    normalize()
    {
        if (this.milliseconds >= 1000) { this.seconds += Math.floor(this.milliseconds / 1000); this.milliseconds %= 1000; }
        if (this.seconds >= 60) { this.minutes += Math.floor(this.seconds / 60); this.seconds %= 60; }
        if (this.minutes >= 60) { this.hours += Math.floor(this.minutes / 60); this.minutes %= 60; }
        if (this.hours >= 24) { this.days += Math.floor(this.hours / 24); this.hours %= 24; }
        this.days += this.months * 30; this.months = 0;
        if (this.days >= 365) { this.years += Math.floor(this.days / 365); this.days %= 365; }
    }

    toYears       (integer = true) { return integer ? (this.normalize()         ?? this.years)  : this.toDays(false)         / 365;                }
    toDays        (integer = true) { return integer ? this.toYears(true)   * 365 + this.days    : this.toHours(false)        / 24;                 }
    toHours       (integer = true) { return integer ? this.toDays(true)    * 24  + this.hours   : this.toMinutes(false)      / 60;                 }
    toMinutes     (integer = true) { return integer ? this.toHours(true)   * 60  + this.minutes : this.toSeconds(false)      / 60;                 }
    toSeconds     (integer = true) { return integer ? this.toMinutes(true) * 60  + this.seconds : this.toMilliseconds(false) / 1000;               }
    toMilliseconds(integer = true) { return integer ? Math.floor(this.toMilliseconds(false))    : this.toSeconds(true) * 1000 + this.milliseconds; }
    
    toFormat()
    {
        let answer = "";
        if (this.years != 0) answer += `${this.years}y`;
        if (this.days != 0) answer += `${this.days}d`;
        if (this.hours != 0) answer += `${this.hours}h`;
        if (this.minutes != 0) answer += `${this.minutes}m`;
        if (this.seconds != 0) answer += `${this.seconds}s`;
        return answer || "0";
    }
};