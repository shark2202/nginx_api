-- sync_cluster_data
-- en : sync master data to slave
-- zn : 同步主节点数据到从节点
-- @author iamtsm
-- @email 1905333456@qq.com

-- cache
local cache_service             =   tlops.cache.service
local cache_limit               =   tlops.cache.limit
local cache_health              =   tlops.cache.health
local cache_balance_api         =   tlops.cache.balance_api
local cache_balance_param       =   tlops.cache.balance_param
local cache_balance_header      =   tlops.cache.balance_header
local cache_balance_cookie      =   tlops.cache.balance_cookie
local cache_balance             =   tlops.cache.balance
local cache_waf_api             =   tlops.cache.waf_api
local cache_waf_ip              =   tlops.cache.waf_ip
local cache_waf_cookie          =   tlops.cache.waf_cookie
local cache_waf_header          =   tlops.cache.waf_header
local cache_waf_cc              =   tlops.cache.waf_cc
local cache_waf_param           =   tlops.cache.waf_param
local cache_waf                 =   tlops.cache.waf
-- utils
local utils                     =   tlops.utils
local nx_socket					=   ngx.socket.tcp
local tl_ops_rt                 =   tlops.constant.comm.tl_ops_rt
local cjson                     =   require("cjson.safe")
cjson.encode_empty_table_as_object(false)
local tlog = require("utils.tl_ops_utils_log"):new("tl_ops_plugin_sync_cluster_data");

local _M = {
    _VERSION = '0.01'
}


--+++++++++++++++路由策略数据同步+++++++++++++++--


-- api策略静态配置数据
local get_sync_cluster_data_balance_api = function ()
    local content = nil

    return content
end

-- cookie策略静态配置数据
local get_sync_cluster_data_balance_cookie = function ()
    local content = nil

    return content
end

-- header策略静态配置数据
local get_sync_cluster_data_balance_header = function ()
    local content = nil

    return content
end

-- param策略静态配置数据
local get_sync_cluster_data_balance_param = function ()
    local content = nil

    return content
end



--+++++++++++++++WAF策略数据同步+++++++++++++++--

-- waf ip策略静态配置数据
local get_sync_cluster_data_waf_ip = function ()
    local content = nil

    return content
end

-- waf api策略静态配置数据
local get_sync_cluster_data_waf_api = function ()
    local content = nil

    return content
end

-- waf cookie策略静态配置数据
local get_sync_cluster_data_waf_cookie = function ()
    local content = nil

    return content
end

-- waf header策略静态配置数据
local get_sync_cluster_data_waf_header = function ()
    local content = nil

    return content
end

-- waf param策略静态配置数据
local get_sync_cluster_data_waf_param = function ()
    local content = nil

    return content
end

-- waf cc策略静态配置数据
local get_sync_cluster_data_waf_cc = function ()
    local content = nil

    return content
end



--+++++++++++++++插件数据同步+++++++++++++++--

-- 获取某个插件
local get_sync_cluster_data_get_plugin = function(name)
    for i = 1, #tlops.plugins do
        local plugin = tlops.plugins[i]
        if plugin.name == name then
            return plugin
        end
    end
    return nil
end

-- 获取插件静态同步数据
local get_sync_cluster_data_plugin = function (module)
    local content = nil
    
    local plugin = get_sync_cluster_data_get_plugin(module)
    if not plugin then
        tlog:err("get_sync_cluster_data_plugin not plugin, module=",module)
        return nil
    end

    if type(plugin.func.get_sync_cluster_data) == 'function' then
        content, _ = plugin.func:get_sync_cluster_data()
        if not content then
            tlog:err("get_sync_cluster_data_plugin err, module=",module, ",content=",content,",err=",_)
            return nil
        end
    end

    tlog:dbg("get_sync_cluster_data_plugin done, module=",module,",content=",content)

    return content
end




-- 获取心跳数据接口
function _M:get_sync_cluster_data_module( modules )

    local socket_content = utils:new_tab(#modules, 0)
    
    for i = 1, #modules do
        local content = nil
        if modules[i] == 'balance_api' then
            content = get_sync_cluster_data_balance_api()
        elseif modules[i] == 'balance_cookie' then
            content = get_sync_cluster_data_balance_cookie()
        elseif modules[i] == 'balance_header' then
            content = get_sync_cluster_data_balance_header()
        elseif modules[i] == 'balance_param' then
            content = get_sync_cluster_data_balance_param()
        elseif modules[i] == 'waf_api' then
            content = get_sync_cluster_data_waf_api()
        elseif modules[i] == 'waf_ip' then
            content = get_sync_cluster_data_waf_ip()
        elseif modules[i] == 'waf_header' then
            content = get_sync_cluster_data_waf_header()
        elseif modules[i] == 'waf_cookie' then
            content = get_sync_cluster_data_waf_cookie()
        elseif modules[i] == 'waf_param' then
            content = get_sync_cluster_data_waf_param()
        elseif modules[i] == 'waf_cc' then
            content = get_sync_cluster_data_waf_cc()
        else
            -- plugin
            content = get_sync_cluster_data_plugin(modules[i] )
        end

        local obj = {}
        obj[modules[i]] = content

        table.insert(socket_content, obj)
    end

    local socket_content_json = cjson.encode(socket_content)

    return socket_content_json
end


return _M