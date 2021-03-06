create or replace procedure ch.saveData(
    @attributes integer default 0,
    @code long varchar default util.HTTPVariableOrHeader ()
)
begin

    message 'ch.saveData ', @UOAuthAccount, ' ', @code, ' #0'
        debug only
    ;
    
    -- entity
    insert into ch.entity on existing update with auto name
    select (select id
              from ch.entity
             where xid = #entity.xid) as id,
           name,
           code,
           if type = 'd' then
                #entity.xmlData
           else
                ch.mergeXml(#entity.xmlData, (select xmlData from ch.entity where xid = #entity.xid))
           endif as xmlData,
           xid
      from #entity
     where xid is not null
       and name is not null
       and ch.entityWriteable(name, @UOAuthRoles) = 1
    ;

    message 'ch.saveData ', @UOAuthAccount, ' ', @code, ' #1'
        debug only
    ;
    
    -- rel
    insert into ch.relationship on existing update with auto name
    select (select id
              from ch.relationship
             where parentXid = #rel.parentXid
               and childXid = #rel.childXid) as [id],
           (select id
              from ch.entity
             where xid = #rel.parentXid) as [parent],
           (select id
              from ch.entity
             where xid = #rel.childXid) as [child],
           #rel.parentXid,
           #rel.childXid,
           #rel.xmlData,
           #rel.name as [role]
      from #rel
     where #rel.parentXid is not null
       and #rel.childXid is not null
       and parent is not null
       and child is not null
       and ch.entityWriteable(#rel.name, @UOAuthRoles) = 1
    ;
    
    message 'ch.saveData ', @UOAuthAccount, ' ', @code, ' #2'
        debug only
    ;
    

    -- delete rel
    delete from ch.relationship
    where parentXid in (select xid from #entity where type = 'd')
      and not exists (
        select *
        from #rel
        where parentXid = ch.relationship.parentXid
            and childXid = ch.relationship.childXid
    );
    
    message 'ch.saveData ', @UOAuthAccount, ' ', @code, ' #end'
        debug only
    ;
        

end;
