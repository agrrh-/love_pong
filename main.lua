function love.load()
    clrBlack = {0, 0, 0}
    clrGray = {64, 64, 64}
    clrWhite = {255, 255, 255}

    mainFont = love.graphics.newFont("res/bebas.ttf", 48);

    w = love.graphics.getWidth()
    h = love.graphics.getHeight()

    platform_w = w/5
    platform_speed = 5
    ball_speed = 10

    ball = {
        {w/2, h/2},
        {ball_speed, ball_speed},
        16
    }

    player = { {w/2, h-16}, platform_w }
    bot = { {w/2, 16}, platform_w }
    controls = 'idle'

    score = {0, 0}
end

function love.draw()
    draw_scores(score)
    draw_ball(ball)
    draw_platform(player)
    draw_platform(bot)
end

function love.keypressed(key, unicode)
    if key == 'escape' then
        r = love.event.quit()
    elseif key == 'a' or key == 'left' then
        controls = 'left'
    elseif key == 'd' or key == 'right' then
        controls = 'right'
    end
end

function love.update(dt)
    ball = move_ball(ball)

    bot_controls = analyse_bot(bot)
    bot, bot_controls = unpack(move_platform(bot, bot_controls, false))

    player, controls = unpack(move_platform(player, controls, true))
end

-- ----------------

function analyse_bot(bot)
    bx, by = unpack(bot[1])

    if x > bx then
        return 'right'
    elseif x < bx then
        return 'left'
    else
        return 'idle'
    end
end

function move_ball(ball)
    local dx, dy

    pos, direction, radius = unpack(ball)
    dx, dy = unpack(direction)
    x, y = unpack(pos)

    dx, dy, tmp_dx, tmp_dy = unpack(handle_borders(dx, dy, 0, 0))
    dx, dy, tmp_dx, tmp_dy = unpack(handle_platforms(dx, dy, tmp_dx, tmp_dy))

    x = x + tmp_dx
    y = y + tmp_dy

    return {{x, y}, {dx, dy}, radius}
end

function handle_platforms(dx, dy, tmp_dx, tmp_dy)
    -- collision with top platform
    bx, by = unpack(bot[1])
    px, py = unpack(player[1])

    if y + dy - radius <= by + 2 then
        if x + dx >= bx - platform_w / 2 and x + dx <= bx + platform_w / 2 then
            if y + dy - radius < by + 2 then
                tmp_dy = by + 2 + radius - y
            end

            dy = dy * -1
        end
    elseif y + dy + radius >= py - 2 then
        if x + dx >= px - platform_w / 2 and x + dx <= px + platform_w / 2 then
            if y + dy + radius > py - 2 then
                tmp_dy = py - 2 - radius - y
            end

            dy = dy * -1
        end
    end

    return {dx, dy, tmp_dx, tmp_dy}
end

function handle_borders(dx, dy, tmp_dx, tmp_dy)
    -- collision with borders
    if x + radius >= w or x - radius <= 0 then
        dx = dx * -1
    end
    if y + radius >= h or y - radius <= 0 then
        dy = dy * -1
    end

    -- change speed so not get out of borders in next move
    tmp_dx = dx
    if x + dx + radius >= w then
        tmp_dx = w - radius - x
    elseif x + dx - radius <= 0 then
        tmp_dx = 0 + radius - x
    end

    tmp_dy = dy
    if y + dy + radius >= h then
        tmp_dy = h - radius - y
        score[2] = score[2] + 1
    elseif y + dy - radius <= 0 then
        tmp_dy = 0 + radius - y
        score[1] = score[1] + 1
    end

    return {dx, dy, tmp_dx, tmp_dy}
end

function move_platform(platform, direction, is_player)
    local dx, dy

    if is_player == true and not love.keyboard.isDown( 'a', 'd', 'left', 'right' ) then
        direction = 'idle'
    end

    pos, width = unpack(platform)
    x, y = unpack(pos)

    if direction == 'left' then
        dx = platform_speed * -1
    elseif direction == 'right' then
        dx = platform_speed
    else
        dx = 0
    end

    if x + dx + width / 2 >= w then
        dx = w - x - width / 2
    elseif x + dx - width / 2 <= 0 then
        dx = 0 - x + width / 2
    end

    x = x + dx

    return { {{x, y}, width}, direction }
end

function draw_platform(platform)
    pos, width = unpack(platform)
    x, y = unpack(pos)

    love.graphics.setColor(clrWhite)
    love.graphics.rectangle("fill", x - width/2, y-2, width, 4)
end

function draw_ball(ball)
    pos, direction, radius = unpack(ball)
    x, y = unpack(pos)

    love.graphics.setFont(mainFont)
    love.graphics.setColor(clrWhite)
    love.graphics.circle('fill', x, y, radius)
end

function draw_scores(score)
    love.graphics.setColor(clrGray)
    love.graphics.printf(score[1], w/2, y/2 + 48, 0, 'center')
    love.graphics.printf(score[2], w/2, y/2 - 96, 0, 'center')
end
