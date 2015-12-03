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
    local bodyA = a:getBody()
    local bodyB = b:getBody()

    if bodyA:isBullet() and bodyB:isBullet() then
        -- Ignore collision
        -- coll:setEnabled(false)
    elseif bodyA:isBullet() then
        -- TODO: Destroy entity B
        -- entities.destroy(b:getUserData())
        -- TODO: Destroy bullet A
        -- entities.destroy(a:getUserData())
    elseif bodyB:isBullet() then
        -- TODO: Destroy entity A
        -- entities.destroy(a:getUserData())
        -- TODO: Destroy bullet B
        -- entities.destroy(b:getUserData())
    end
end

function collisions.endContact(a, b, coll)

end

function collisions.preSolve(a, b, coll)

end

function collisions.postSolve(a, b, coll, normalimpulse1, tangentimpulse1, normalimpulse2, tangentimpulse2)

end
