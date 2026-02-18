# Database Assignment: SEPTA GTFS & Philadelphia Spatial Data Analysis

## 项目概述

本项目使用PostgreSQL和PostGIS对费城公交系统（SEPTA）GTFS数据以及Philadelphia地理和人口普查数据进行空间分析。

## 数据库结构

### Schemas
- **septa**: SEPTA公交和轨道交通数据
- **phl**: Philadelphia地理数据（地块parcels和neighborhoods）
- **census**: 美国人口普查数据

### 主要表

#### septa Schema
- `bus_stops`: 公交车站（13,798条记录）
  - 字段：stop_id, stop_name, stop_lat, stop_lon, wheelchair_boarding等
- `bus_routes`: 公交线路（167条记录）
  - 字段：route_id, route_short_name, route_long_name等
- `bus_trips`: 公交行程（连接routes和shapes）
  - 字段：trip_id, route_id, service_id, shape_id等
- `bus_shapes`: 公交线路几何形状点（用于构建路线）
  - 字段：shape_id, shape_pt_lat, shape_pt_lon, shape_pt_sequence
- `rail_stops`: 轨道交通车站（57条记录）
  - 字段：stop_id, stop_name, stop_lat, stop_lon

#### phl Schema
- `pwd_parcels`: Philadelphia Water Department地块数据（10,173条记录）
  - 地理列：geog (GEOGRAPHY类型)
- `neighborhoods`: Philadelphia neighborhoods（160个neighborhood）
  - 地理列：geog (GEOGRAPHY类型)

#### census Schema
- `blockgroups_2020`: 2020美国人口普查区块（Pennsylvania地理数据）
  - 地理列：geog (GEOGRAPHY类型)
- `population_2020`: 2020人口数据（按block group）
  - 字段：geoid, geoname, total(人口)

## Query说明

### Query 01: 8个人口最多的公交车站（800米范围内）
**文件**: query01.sql
**方法**:
1. 用ST_DWithin查找每个bus stop 800米范围内的census block groups
2. 使用block group geoid连接population_2020获取人口数据
3. 按总人口从大到小排序

**结果样本**:
- Lombard St & 18th St: 57,936人
- Rittenhouse Sq & 18th St: 57,571人

### Query 02: 8个人口最少的公交车站（Philadelphia，800米范围内，>500人）
**文件**: query02.sql
**方法**:
1. 过滤geoid前缀为42101（Philadelphia County）的census block groups
2. 只考虑总人口>500的车站
3. 按人口从小到大排序

**结果样本**:
- BARTRAM_VILLAGE: 0% (0/14 stops accessible)
- WOODLAND_TERRACE: 20% (2/10 stops)

### Query 03: 每个Parcel最近的公交车站
**文件**: query03.sql
**方法**:
1. 使用LATERAL JOIN进行最近邻搜索
2. 用KNN操作符(<->)优化邻近搜索
3. 计算距离并按从大到小排序
**性能**: 可能需要2-3分钟（140M行数据）

### Query 04: 最长的两条公交线路
**文件**: query04.sql
**方法**:
1. 连接bus_routes, bus_trips, bus_shapes表
2. 使用ST_MakeLine从shape点构建线
3. 计算每条路线的总长度
4. 按长度排序取前2

**结果**:
- MFL (69th Street): 122米
- MFL (Frankford): 119米

### Query 05 & 06: Neighborhoods轮椅无障碍度评分
**文件**: query05.sql (前5), query06.sql (后5)
**无障碍度指标**:
- 定义：(有无障碍的stops数 / 总stops数) × 100
- wheelchair_boarding = 1 表示有无障碍设施
- wheelchair_boarding = 0 或 2 表示无无障碍设施

**方法**:
1. 使用ST_Intersects找到每个neighborhood内的bus stops
2. 计算无障碍和不可达stops的数量
3. 计算无障碍度百分比

**前5个neighborhood** (100% 无障碍):
- ALLEGHENY_WEST (96 stops)
- ANDORRA (20 stops)
- ASTON_WOODBRIDGE (29 stops)

**后5个neighborhood** (最低无障碍度):
- BARTRAM_VILLAGE (0% - 0/14)
- WOODLAND_TERRACE (20% - 2/10)
- SOUTHWEST_SCHUYLKILL (43.4% - 23/53)

### Query 07: Penn主校园包含的Census Block Groups数量
**文件**: query07.sql
**定义**: 使用UNIVERSITY_CITY neighborhood作为Penn主校园的边界
**方法**: 用ST_Contains检查有多少个block group完全被包含
**结果**: 11个block groups

### Query 08: Meyerson Hall所在的Census Block Group
**文件**: query08.sql
**方法**:
1. 使用Meyerson Hall的坐标：39.9523376, -75.1925003
2. 使用ST_Contains检查该点在哪个block group内
3. 返回block group的geoid
**结果**: 421010192005

### Query 09: Rail Stops描述信息生成
**文件**: query09.sql
**方法**:
1. 对每个rail stop找最近的bus stop（LATERAL JOIN + KNN）
2. 计算距离（米）
3. 使用ST_Azimuth计算方向（N, NE, E, SE, S, SW, W, NW）
4. 生成描述："X meters [方向] of [bus stop名称]"

**结果样本**:
- Cynwyd: "61 meters SW of Bala Av & Montgomery Av"
- Suburban Station: "31 meters NW of JFK Blvd & 17th St"

## 关键PostGIS函数使用

- **ST_DWithin**: 检查两个地理对象是否在指定距离内
- **ST_Contains**: 检查一个geometry是否包含另一个
- **ST_Intersects**: 检查两个geometry是否相交
- **ST_Distance**: 计算两个地理对象之间的距离
- **ST_Azimuth**: 计算从一点到另一点的方位角（弧度）
- **ST_MakeLine**: 从点数组构建线
- **ST_Length**: 计算线的长度
- **ST_SetSRID**: 设置几何的坐标参考系统
- **ST_Point**: 从坐标创建点
- **KNN操作符(<->)**: 用于距离排序的索引优化

## 索引

已创建以下索引以优化查询性能:

```sql
-- B-tree indexes
CREATE INDEX idx_bus_stops_stop_id ON septa.bus_stops(stop_id);
CREATE INDEX idx_bus_routes_route_id ON septa.bus_routes(route_id);
CREATE INDEX idx_bus_trips_trip_id ON septa.bus_trips(trip_id);
CREATE INDEX idx_bus_shapes_shape_id ON septa.bus_shapes(shape_id);
CREATE INDEX idx_population_geoid ON census.population_2020(geoid);

-- GIST indexes for spatial queries
CREATE INDEX idx_pwd_parcels_geog ON phl.pwd_parcels USING GIST(geog);
CREATE INDEX idx_neighborhoods_geog ON phl.neighborhoods USING GIST(geog);
CREATE INDEX idx_blockgroups_geog ON census.blockgroups_2020 USING GIST(geog);
```

## 数据导入说明

### SEPTA数据（CSV）
```bash
COPY septa.bus_stops FROM 'path/to/stops.txt' WITH (FORMAT csv, HEADER true);
COPY septa.bus_routes FROM 'path/to/routes.txt' WITH (FORMAT csv, HEADER true);
COPY septa.bus_trips FROM 'path/to/trips.txt' WITH (FORMAT csv, HEADER true);
COPY septa.bus_shapes FROM 'path/to/shapes.txt' WITH (FORMAT csv, HEADER true);
COPY septa.rail_stops FROM 'path/to/stops.txt' WITH (FORMAT csv, HEADER true);
```

### 地理数据（Shapefile/GeoJSON）
```bash
ogr2ogr -f "PostgreSQL" PG:"..." -nln phl.pwd_parcels \
    -nlt MULTIPOLYGON -t_srs EPSG:4326 \
    -lco GEOMETRY_NAME=geog -overwrite PWD_PARCELS.shp

ogr2ogr -f "PostgreSQL" PG:"..." -nln phl.neighborhoods \
    -nlt MULTIPOLYGON -lco GEOMETRY_NAME=geog \
    -overwrite Neighborhoods_Philadelphia.geojson

ogr2ogr -f "PostgreSQL" PG:"..." -nln census.blockgroups_2020 \
    -nlt MULTIPOLYGON -t_srs EPSG:4326 \
    -lco GEOMETRY_NAME=geog -overwrite tl_2020_42_bg.shp
```

### Census人口数据
```bash
COPY census.population_2020 (geoid, geoname, total) 
FROM 'path/to/population.csv' WITH (FORMAT csv, HEADER true);
```

## 技术细节

### 坐标参考系统
- **输入**: EPSG:2272 (feet, for PWD parcels), EPSG:4269 (Census), EPSG:4326 (standard WGS84)
- **输出**: EPSG:4326 (WGS84 latitude/longitude)
- **Geography类型**: 使用球面距离计算，无需手动投影

### 性能考虑
- Query 03（最近邻）可能需要2-3分钟，因为涉及140M行的笛卡尔积
- Query 04中使用ST_MakeLine和ST_Length可能较慢，替代方案是使用shape_dist_traveled字段
- GIST索引显著加速空间查询

## 文件清单

- `query01.sql` - 8个人口最多的公交车站
- `query02.sql` - 8个人口最少的公交车站
- `query03.sql` - Parcel最近的公交车站
- `query04.sql` - 最长的两条公交线路
- `query05.sql` - Neighborhoods无障碍度（前5）
- `query06.sql` - Neighborhoods无障碍度（后5）
- `query07.sql` - Penn校园包含的block groups数量
- `query08.sql` - Meyerson Hall所在的block group
- `query09.sql` - Rail stops描述信息生成
- `db_structure.sql` - 完整的数据库schema定义

## 注记

1. **Query 03性能**: 最近邻查询在大数据集上很慢。在实际应用中可以考虑使用子采样或空间索引分区。

2. **无障碍度指标（Query 05-06）**: 当前指标只考虑轮椅无障碍（wheelchair_boarding字段）。实际的无障碍评估应包括其他因素如电梯、坡道、盲道等。

3. **Penn校园定义（Query 07）**: 使用UNIVERSITY_CITY neighborhood作为Penn主校园的代理。更精确的定义可以使用Penn的官方campus boundary数据。

4. **地理准确性**: 所有空间查询都使用球面计算（geography类型），对于费城这样的小区域，误差可以忽略不计。

---

**Created**: February 18, 2026
**Database**: assignment2 (PostgreSQL + PostGIS)
**Data Sources**: SEPTA GTFS, OpenDataPhilly, US Census Bureau
