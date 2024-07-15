function startup()
	gcs:send_text(0, "start")
	return update()
end

function sign_of_num(num)
	-- returns true if > 0, false if < 0
	return num > 0
end

-- Maps a number from one range to another:
-- [in_min, in_max] -> [out_min, out_max]
function map(x, in_min, in_max, out_min, out_max)
	return out_min + (x - in_min) * (out_max - out_min) / (in_max - in_min)
end

function update()
	local velocity_NED = ahrs:get_velocity_NED()
	local wp_bearing_deg = vehicle:get_wp_bearing_deg()

	if not velocity_NED then
		gcs:send_text(0, "is nil")
	else
		local north_velocity = velocity_NED:x() -- North velocity
		local east_velocity = velocity_NED:y() -- East velocity
		local down_velocity = velocity_NED:z() -- Down velocity

		local flying_direction_deg = 0
		if sign_of_num(north_velocity) == sign_of_num(east_velocity) then
			flying_direction_deg = math.deg(math.atan(math.abs(east_velocity), math.abs(north_velocity)))
		else
			flying_direction_deg = math.deg(math.atan(math.abs(north_velocity), math.abs(east_velocity)))
		end


		if north_velocity < 0 and east_velocity > 0 then
			flying_direction_deg = flying_direction_deg + 90
		end
		if north_velocity < 0 and east_velocity < 0 then
			flying_direction_deg = flying_direction_deg + 180
		end
		if north_velocity > 0 and east_velocity < 0 then
			flying_direction_deg = flying_direction_deg + 270
		end

		gcs:send_text(0, "North Velocity: " .. tostring(north_velocity) .. ' m/s')
		gcs:send_text(0, "East Velocity: " .. tostring(east_velocity) .. ' m/s')
		gcs:send_text(0, "Down Velocity: " .. tostring(down_velocity) .. ' m/s')
		gcs:send_text(0, "flying direction: " .. tostring(flying_direction_deg) .. ' deg')
		gcs:send_text(0, "wp bearing deg: " .. tostring(wp_bearing_deg) .. ' deg')

		local pwm_output = map(math.abs(wp_bearing_deg - flying_direction_deg), 0, 180, 1000, 2000)

		gcs:send_text(0, "pwm output: " .. tostring(pwm_output) .. ' PWM')
	end
	return update, 20
end

return startup()
