create or replace function ch.responseRootElement(
    @response xml
)
returns xml
begin
    declare @result xml;
    
    set @result = xmlelement('response', xmlattributes('https://github.com/sys-team/ASA.chest' as "xmlns",now() as "ts"), @response);
    
    return @result;
end
;