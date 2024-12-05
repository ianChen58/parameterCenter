<template>
    <ul>
        <el-form :model="node" ref="form" abel-width="auto">
            <li>
                <el-row :gutter="2" style="padding-bottom: 10px;">
                    <el-col :span="6">
                        <!-- show group key -->
                        <div v-if="node.type === 'Map'">
                            <el-button text @click="node.hide = !node.hide" style="margin: 0; padding: 5px; ">
                                <svg v-if="node.hide" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
                                    <path
                                        d="m14.707 12.707-4 4a1 1 0 0 1-1.414-1.414L12.586 12 9.293 8.707a1 1 0 1 1 1.414-1.414l4 4a1 1 0 0 1 0 1.414z" />
                                </svg>
                                <svg v-if="!node.hide" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
                                    <path
                                        d="M12 15a1 1 0 0 1-.707-.293l-4-4a1 1 0 1 1 1.414-1.414L12 12.586l3.293-3.293a1 1 0 0 1 1.414 1.414l-4 4A1 1 0 0 1 12 15z" />
                                </svg>
                            </el-button>
                            <el-button size="small" circle @click="showAddNodeDialog = true; cleanAddFrom();"
                                style="margin: 0;">+</el-button>
                            <el-popover :visible="node.visible === true" placement="top" :width="200">
                                <p>Are you sure to delete this?</p>
                                <div style="text-align: right; margin: 0">
                                    <el-button size="small" text @click="node.visible = false">cancel</el-button>
                                    <el-button size="small" type="primary" @click="node.visible = false; removeNode()">
                                        confirm
                                    </el-button>
                                </div>
                                <template #reference>
                                    <el-button size="small" @click="node.visible = true" circle
                                        style="margin: 0;">x</el-button>
                                </template>
                            </el-popover>

                            <!-- add a new node dialog -->
                            <el-dialog title="Add New Template" v-model="showAddNodeDialog" center>
                                <el-form :model="addFrom">
                                    <el-form-item label="Name" label-width="150px" :required="true">
                                        <el-input v-model="addFrom.name" placeholder="Template Name"></el-input>
                                    </el-form-item>
                                    <el-form-item label="Type" label-width="150px" :required="true">
                                        <el-select v-model="addFrom.type"
                                            placeholder="Config type[Map,Collection,String,Number]">
                                            <el-option label="String" value="String"></el-option>
                                            <el-option label="Map" value="Map"></el-option>
                                            <el-option label="Percent" value="Percent"></el-option>
                                            <el-option label="Number" value="Number"></el-option>
                                            <el-option label="Number.Integer" value="Number.Integer"></el-option>
                                            <el-option label="Number.Long" value="Number.Long"></el-option>
                                            <el-option label="@ConditionOn()" value="@ConditionOn()"></el-option>
                                            <el-option label="Other" value="Other"></el-option>
                                        </el-select>
                                    </el-form-item>
                                    <el-form-item v-if="addFrom.type !== 'Map'" label="Scope" label-width="150px"
                                        :required="true">
                                        <el-input v-model="addFrom.scope"
                                            placeholder="Config scope[Product,Contract,ConditionOn...]"></el-input>
                                    </el-form-item>
                                    <el-form-item v-if="addFrom.type !== 'Map'" label="Default Value"
                                        label-width="150px">
                                        <el-input v-model="addFrom.defaultValue" placeholder="Default Value"></el-input>
                                    </el-form-item>
                                    <el-form-item v-if="addFrom.type !== 'Map'" label="Allowed" label-width="150px">
                                        <el-input v-model="addFrom.allowed" placeholder="Allowed value"></el-input>
                                    </el-form-item>
                                    <el-form-item v-if="addFrom.type !== 'Map'" label="Required On Signing"
                                        label-width="150px">
                                        <el-input v-model="addFrom.requiredOnSigning"
                                            placeholder="Yes,No,Opt,Sys,' '"></el-input>
                                    </el-form-item>
                                </el-form>

                                <template #footer>
                                    <div class="dialog-footer">
                                        <el-button @click="showAddNodeDialog = false">Cancel</el-button>
                                        <el-button type="primary"
                                            @click="addNode(addFrom.name, addFrom.type, addFrom.scope, addFrom.defaultValue, addFrom.allowed, addFrom.requiredOnSigning); showAddNodeDialog = false">Confirm</el-button>
                                    </div>
                                </template>
                            </el-dialog>


                            <span v-show="!node.edit">
                                <span style="font-weight: 800;"
                                    @click="node.keyt = node.name; node.edit = true; focus(node.name)">{{
                                        node.name }}</span>
                            </span>
                            <el-input style="width: 60%;" v-if="node.edit" :ref='node.name' v-model="node.keyt"
                                @blur="handleInputBlur" @keydown.enter="handleInputBlur" size="small" autosize />
                        </div>

                        <!-- show param key -->
                        <div v-if="node.type !== 'Map'" style="word-wrap: break-word; overflow-wrap: break-word;">
                            <el-popover :visible="node.visible === true" placement="top" :width="200">
                                <p>Are you sure to delete this?</p>
                                <div style="text-align: right; margin: 0">
                                    <el-button size="small" text @click="node.visible = false">cancel</el-button>
                                    <el-button size="small" type="primary" @click="node.visible = false; removeNode()">
                                        confirm
                                    </el-button>
                                </div>
                                <template #reference>
                                    <el-button size="small" @click="node.visible = true" circle
                                        style="margin: 0;">x</el-button>
                                </template>
                            </el-popover>
                            <span v-show="!node.edit">
                                <span style="font-weight: 400;"
                                    @click="node.keyt = node.name; node.edit = true; focus(node.name)">{{
                                        node.name }}</span>
                            </span>
                            <el-input style="width: 80%;" v-show="node.edit" :ref='node.name' v-model="node.keyt"
                                @blur="handleInputBlur" @keydown.enter="handleInputBlur" size="small" autosize />
                        </div>
                    </el-col>
                    <!-- show the value -->
                    <el-col :span="3">
                        <el-input v-if="node.type !== 'Map'" v-model="node.defaultValue" type="textarea"
                            placeholder="defaultValue" autosize />
                    </el-col>
                    <el-col :span="3">
                        <el-input v-if="node.type !== 'Map'" v-model="node.allowed" type="textarea"
                            placeholder="allowed" autosize />
                    </el-col>
                    <el-col :span="2">
                        <el-input v-if="node.type !== 'Map'" v-model="node.requiredOnSigning" type="textarea"
                            placeholder="require" autosize />
                    </el-col>
                    <el-col :span="3">
                        <el-input v-if="node.type !== 'Map'" v-model="node.scope" type="textarea" placeholder="scope"
                            autosize />
                    </el-col>
                    <el-col :span="5">
                        <el-input v-if="node.type !== 'Map'" v-model="node.type" type="textarea" placeholder="type"
                            autosize />
                    </el-col>
                    <el-col :span="2">
                        <el-input v-if="node.type !== 'Map'" v-model="node.parent" type="textarea" placeholder="parent"
                            autosize />
                    </el-col>

                </el-row>
                <editTemplate v-if="!node.hide" v-for="nodeChildren in node.children" :node="nodeChildren"
                    :children="node.children" :globalFold="globalFold" />
            </li>
        </el-form>
    </ul>
</template>

<script>

export default {
    data() {
        return {
            addFrom: {
                name: '',
                type: 'Map',
                scope: '',
                defaultValue: '',
                allowed: '',
                requiredOnSigning: '',
            },
            showAddNodeDialog: false,
        };
    },
    mounted() {
    },
    methods: {
        cleanAddFrom() {
            this.addFrom = {
                name: '',
                type: 'Map',
                scope: '',
                defaultValue: '',
                allowed: '',
                requiredOnSigning: '',
            }
        },
        addNode(name, type, scope, defaultValue, allowed, requiredOnSigning) {
            if (!name) name = 'Default Name'
            if (type !== 'Map') {
                if (!scope) scope = 'Default Scope'
            }
            for (let child of this.node.children) {
                if (child.name === name) {
                    this.$message.error('Key Already Exist!');
                    return;
                }
            }
            this.node.children.unshift({
                name: name,
                type: type,
                scope: scope,
                defaultValue: defaultValue,
                allowed: allowed,
                requiredOnSigning: requiredOnSigning,
                parent: this.node.name,
                children: []
            });
            this.$message.success('Node add successfully!');
        },
        removeNode() {
            this.children.splice(this.children.indexOf(this.node), 1);
            this.$message.success('Node removed successfully!');
        },
        focus(key) {
            // console.log(key, 'focus')
            let _this = this
            setTimeout(function () {
                _this.$refs[key].focus();
            }, 10)
        },
        handleInputBlur() {
            // 验证输入是否为重复
            if (this.node.keyt === this.node.name) {
                this.node.edit = false;
                return;
            }
            // 验证兄弟节点是否存在重复
            for (let sibling of this.children) {
                if (sibling.name === this.node.keyt) {
                    this.$message.error('Key Already Exist!');
                    this.node.edit = false;
                    return;
                }
            }
            // 输入验证通过，更新节点数据
            if (this.node.keyt) {
                this.node.name = this.node.keyt;
                // 将children中的所有节点的parent更新为当前节点的name
                for (let child of this.node.children) {
                    child.parent = this.node.name;
                }
            } else {
                this.$message.warning('Input cannot be empty');
                this.node.keyt = this.node.name;
            }
            this.node.edit = false;
        },
        syncChildrenFold(children, fold) {
            if (!children || children.length === 0) return;
            children.forEach((child) => {
                child.hide = fold;
                if (child.children) {
                    this.syncChildrenFold(child.children, fold);
                }
            });
        },
    },
    props: {
        node: {
            type: Object,
            default: {}
        },
        children: {
            type: Array,
            default: []
        },
        globalFold: {
            type: Boolean,
            default: false
        }
    },
    watch: {
        globalFold(newVal) {
            if (newVal !== null) {
                this.node.hide = newVal;
                this.syncChildrenFold(this.node.children, newVal);
            }
        },
    },
}
</script>

<style scoped>
svg {
    height: 1em;
    width: 1em;
    color: black;
}
</style>