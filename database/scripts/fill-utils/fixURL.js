export default function fixURL(value)
{
    if (typeof value !== "string" || !value.startsWith("https://") || value.startsWith("https://domain.domain")) return("https://example.com");
    return value;
}