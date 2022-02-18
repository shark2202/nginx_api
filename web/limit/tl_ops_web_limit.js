const _limit_view_id_name = "tl-ops-web-limit-service-view";
const _limit_tlp_id_name = "tl-ops-web-limit-service-tpl";
const _limit_form_btn_id_name = "tl-ops-web-limit-btn";
const _limit_form_perfix_id_name = "tl-ops-web-limit-form-";

const _add_form_btn_id_name = "tl-ops-web-limit-form-submit"

let res_data = {};

const tl_ops_web_limit_main = function (){
    window.$ = layui.$;
    window.form = layui.form;
    window.table = layui.table;
    window.laytpl = layui.laytpl;
    window.element = layui.element;

    axios.get("/tlops/limit/list").then((res)=>{
        res = res.data;
        if(res.code === 0){
            res_data = res.data;
            tl_ops_web_limit_render(res_data.tl_ops_limit_fuse_options_list)
        }
    })
};


const tl_ops_web_limit_render = function( data ){
    laytpl(document.getElementById(_limit_tlp_id_name).innerHTML).render((()=>{
        return data;
    })(), (html)=>{
        document.getElementById(_limit_view_id_name).innerHTML = html;
    });
    form.render()
}


//管理节点
const tl_ops_web_limit_edit = function (name) {
    let index = layer.open({
        type: 2
        ,title: '管理【'+name+'】熔断限流配置'
        ,content: 'tl_ops_web_limit_form.html?service='+name
        ,maxmin: true
        ,minStack:false
        ,area: ['600px', '650px']
        ,btn: ['确定', '取消']
        ,yes: function(index, dom){
            let iframeWindow = window['layui-layer-iframe'+ index]
                ,submit = dom.find('iframe').contents().find('#'+ _add_form_btn_id_name);

            iframeWindow.layui.form.on('submit('+ _add_form_btn_id_name +')', function(data){
                if(!tl_ops_limit_data_edit_filter(data)){
                    return;
                }
                $.ajax(tl_ajax_data({
                    url: '/tlops/limit/set',
                    data : JSON.stringify(res_data),
                    contentType : "application/json",
                    success : (res)=>{
                        layer.msg(res.msg)
                        tl_ops_web_limit_render(res_data.tl_ops_limit_fuse_options_list)
                    }
                }));
                layer.close(index);
            });
            submit.trigger('click');
        },
        success: function(dom, index) {
            let evtdata = res_data.tl_ops_limit_fuse_options_list.filter((item)=>{
                return item.service_name === name;
            })
            if (evtdata && evtdata.length === 1){
                let editForm = dom.find('iframe')[0].contentWindow;
                editForm.tl_ops_web_limit_form_render(evtdata[0]);
            }else{
                layer.msg("渲染编辑框失败")
            }
        },
    });
};


//过滤数据
const tl_ops_limit_data_edit_filter = function( data ) {
    for(let key in data.field){
        if(data.field[key] === undefined || data.field[key] === null || data.field[key] === ''){
            layer.msg(key + "未填写")
            return false;
        }
        if(key === 'interval'){
            data.field[key] = parseInt(data.field[key])
        }
        if(key === 'node_threshold'){
            data.field[key] = parseFloat(data.field[key])
        }
        if(key === 'service_threshold'){
            data.field[key] = parseFloat(data.field[key])
        }
        if(key === 'recover'){
            data.field[key] = parseInt(data.field[key])
        }
    }
    let cur_list = []
    res_data.tl_ops_limit_fuse_options_list.forEach((item)=>{
        if(item.service_name === data.field.service_name){
            item = data.field;
        }
        cur_list.push(item)
    })
    res_data.tl_ops_limit_fuse_options_list = cur_list;

    return true;
}