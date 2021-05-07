local Clustering = require "clustering"


-- Controllerクラス（？）
local Controller = { }
Controller.new = function( )
	local instance = { }
	instance.__clustering = { }
	instance.__data_objects = { }
	instance.__positions = { }

	instance.initialize = function(self)
		for i = 0, 19 do
			self.__data_objects[i] = vci.assets.GetSubItem("Data (" .. tostring(i) .. ")")
		end
		self:__set_positions( )
		self.__clustering = Clustering.new(self.__positions, 3)
		self.__clustering:initialize( )
	end

	instance.__set_positions = function(self)
		-- データをランダムに配置します。
		for i = 0, 19 do
			local x = math.random( )
			local y = math.random( )
			local z = math.random( )
			local random_vector = Vector3.__new(x, y, z)
			self.__positions[i] = random_vector
			self.__data_objects[i].SetLocalPosition(random_vector)
		end
	end

	instance.__get_positions = function(self)
		-- データの座標を再取得します。
		local datas = self.__clustering:get_datas( )
		for i = 0, 19 do
			local position = self.__data_objects[i].GetLocalPosition( )
			datas[i]:set_position(position)
		end
	end

	instance.__set_data_object_color = function(self, clusters)
		-- クラスター番号に合わせて，Dataオブジェクトの色を変更します。
		-- param clusters: クラスター番号の配列
		for i = 0, 19 do
			if clusters[i] == 0 then
				-- ここではマテリアル名（Data n）を使う。
				vci.assets.material._ALL_SetColor("Data " .. i, Color.__new(0.625, 1.0, 1.0))
			end
			if clusters[i] == 1 then
				vci.assets.material._ALL_SetColor("Data " .. i, Color.__new(1.0, 0.625, 1.0))
			end
			if clusters[i] == 2 then
				vci.assets.material._ALL_SetColor("Data " .. i, Color.__new(1.0, 1.0, 0.625))
			end
		end
	end

	instance.on_button_next_use = function(self)
		-- ボタンを押したときのイベントハンドラー。クラスタリングを実行し，結果に合わせて色を変える。
		print("座標取得")
		self:__get_positions( )
		print("k-meansするよ")
		self.__clustering:k_means( )
		local datas = self.__clustering:get_datas( )
		print("データ数：" .. #datas + 1 .. " 個")
		local clusters = { }
		for i = 0, #datas do
			clusters[i] = datas[i]:get_cluster( )
		end
		self:__set_data_object_color(clusters)
	end


	return instance
end
return Controller
