collisions = {}

function collisions.contactFilter(a, b)
    local A = entities.get(a:getUserData())
    local B = entities.get(b:getUserData())

    if A ~= nil and B ~= nil then
        local bullet_bullet = a:getBody():isBullet() and b:getBody():isBullet()
        local player_bullet = A.type == 'player' and b:getBody():isBullet() or B.type == 'player' and a:getBody():isBullet()
        if bullet_bullet or player_bullet then
            return false
        end
    end
    return true
end

function collisions.beginContact(a, b, coll)
end

function collisions.endContact(a, b, coll)

end

function collisions.preSolve(a, b, coll)

end

function collisions.postSolve(a, b, coll, normalimpulse1, tangentimpulse1, normalimpulse2, tangentimpulse2)

    local bodyA = a:getBody()
    local bodyB = b:getBody()

    local A = entities.get(a:getUserData())
    local B = entities.get(b:getUserData())

    -- Check for bullet collision with walls
    if A == nil and B == nil then
        -- No action if both objects are not entities
        return
    elseif A == nil and B ~= nil then
        -- Remove bullet if one object is a wall and the other is a bullet
        if bodyA:getType() == 'static' and (B.type == 'bullet' or B.type == 'missile') then
            entities.destroy(B.id)
        end
        return
    elseif A ~= nil and B == nil then
        -- Remove bullet if one object is a bullet and the other is a wall
        if (A.type == 'bullet' or A.type == 'missile') and bodyB:getType() == 'static' then
            entities.destroy(A.id)
        end
        return
    end

    -- Do damage to enemies when colliding with bullets
    if A.type == 'bullet' and B.type == 'enemy' then
        B:hit(A.owner.weapon.damagePerBullet)
        entities.destroy(A.id)
    elseif A.type == 'enemy' and B.type == 'bullet' then
        A:hit(B.owner.weapon.damagePerBullet)
        entities.destroy(B.id)

    -- Explode missiles and kill enemy when in contact with enemy
    elseif A.type == 'missile' and B.type == 'enemy' then
        B:kill()
        A:explode()
    elseif A.type == 'enemy' and B.type == 'missile' then
        A:kill()
        B:explode()

    -- Kill player when contacted by enemy
    elseif A.type == 'player' and B.type == 'enemy' then
        A:die()
        -- print('Player killed by ' .. B.type)
    elseif A.type == 'enemy' and B.type == 'player' then
        B:die()
        -- print('Player killed by ' .. A.type)
    end
end
