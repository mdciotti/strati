collisions = {}

function collisions.contactFilter(a, b)
    local bullet_bullet = a:getBody():isBullet() and b:getBody():isBullet()
    local player_bullet = a:getUserData() == 'player' and b:getBody():isBullet() or b:getUserData() == 'player' and a:getBody():isBullet()
    if bullet_bullet or player_bullet then
        return false
    else
        return true
    end
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
        if bodyA:getType() == 'static' and B.type == 'bullet' then
            entities.destroy(B.id)
        end
        return
    elseif A ~= nil and B == nil then
        -- Remove bullet if one object is a bullet and the other is a wall
        if A.type == 'bullet' and bodyB:getType() == 'static' then
            entities.destroy(A.id)
        end
        return
    end

    -- Do damage to enemies when colliding with bullets
    if A.type == 'bullet' and B.type == 'box' then
        B:hit(A.owner.weapon.damagePerBullet)
        entities.destroy(A.id)
    elseif A.type == 'box' and B.type == 'bullet' then
        A:hit(B.owner.weapon.damagePerBullet)
        entities.destroy(B.id)
    elseif A.type == 'player' and B.type == 'box' then
        A:die()
        -- print('Player killed by ' .. B.type)
    elseif A.type == 'box' and B.type == 'player' then
        B:die()
        -- print('Player killed by ' .. A.type)
    end
end
