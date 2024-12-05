<template>
    <ul>
        <el-form :model="node.data" ref="form" abel-width="auto">
            <li>
                <el-row :gutter="2" style="padding-bottom: 10px;">
                    <el-col :span="10">
                        <!-- show group key -->
                        <div v-if="node.data.type === 'Group'">
                            <el-button text @click="node.data.hide = !node.data.hide" style="margin: 0; padding: 5px; ">
                                <svg v-if="node.data.hide" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
                                    <path
                                        d="m14.707 12.707-4 4a1 1 0 0 1-1.414-1.414L12.586 12 9.293 8.707a1 1 0 1 1 1.414-1.414l4 4a1 1 0 0 1 0 1.414z" />
                                </svg>
                                <svg v-if="!node.data.hide" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
                                    <path
                                        d="M12 15a1 1 0 0 1-.707-.293l-4-4a1 1 0 1 1 1.414-1.414L12 12.586l3.293-3.293a1 1 0 0 1 1.414 1.414l-4 4A1 1 0 0 1 12 15z" />
                                </svg>
                            </el-button>
                            <el-button size="small" circle
                                @click="showAddNodeDialog = true; addFrom.key = ''; addFrom.value = ''"
                                style="margin: 0;">+</el-button>
                            <el-popover :visible="node.data.visible === true" placement="top" :width="200">
                                <p>Are you sure to delete this?</p>
                                <div style="text-align: right; margin: 0">
                                    <el-button size="small" text @click="node.data.visible = false">cancel</el-button>
                                    <el-button size="small" type="primary"
                                        @click="node.data.visible = false; removeNode()">
                                        confirm
                                    </el-button>
                                </div>
                                <template #reference>
                                    <el-button size="small" @click="node.data.visible = true" circle
                                        style="margin: 0;">x</el-button>
                                </template>
                            </el-popover>

                            <el-dialog title="Choose Node Type" v-model="showAddNodeDialog" center>
                                <el-form :model="addFrom">
                                    <el-form-item label="Param Type" label-width="150px">
                                        <el-select v-model="addFrom.type" placeholder="Select node type">
                                            <el-option label="Param" value="Param"></el-option>
                                            <el-option label="Group" value="Group"></el-option>
                                        </el-select>
                                    </el-form-item>
                                    <el-form-item label="Param Key" label-width="150px" :required="true">
                                        <el-input v-model="addFrom.key"></el-input>
                                    </el-form-item>
                                    <el-form-item v-if="addFrom.type !== 'Group'" label="Param Value"
                                        label-width="150px" :required="true">
                                        <el-input v-model="addFrom.value"></el-input>
                                    </el-form-item>

                                </el-form>

                                <template #footer>
                                    <div class="dialog-footer">
                                        <el-button @click="showAddNodeDialog = false">Cancel</el-button>
                                        <el-button type="primary"
                                            @click="addNode(addFrom.key, addFrom.value, addFrom.type); showAddNodeDialog = false">Confirm</el-button>
                                    </div>
                                </template>
                            </el-dialog>


                            <span v-show="!node.data.edit">
                                <span style="font-weight: 800;"
                                    @click="node.data.keyt = node.data.key; node.data.edit = true; focus(node.data.key)">{{
                                        node.data.key }}</span>
                            </span>
                            <el-input style="width: 60%;" v-if="node.data.edit" :ref='node.data.key'
                                v-model="node.data.keyt" @blur="handleInputBlur" @keydown.enter="handleInputBlur"
                                size="small" autosize />
                        </div>

                        <!-- show param key -->
                        <div v-if="node.data.type === 'Param'"
                            style="word-wrap: break-word; overflow-wrap: break-word;">
                            <el-popover :visible="node.data.visible === true" placement="top" :width="200">
                                <p>Are you sure to delete this?</p>
                                <div style="text-align: right; margin: 0">
                                    <el-button size="small" text @click="node.data.visible = false">cancel</el-button>
                                    <el-button size="small" type="primary"
                                        @click="node.data.visible = false; removeNode()">
                                        confirm
                                    </el-button>
                                </div>
                                <template #reference>
                                    <el-button size="small" @click="node.data.visible = true" circle
                                        style="margin: 0;">x</el-button>
                                </template>
                            </el-popover>
                            <span v-show="!node.data.edit">
                                <span style="font-weight: 400;"
                                    @click="node.data.keyt = node.data.key; node.data.edit = true; focus(node.data.key)">{{
                                        node.data.key }}</span>
                            </span>
                            <el-input style="width: 80%;" v-show="node.data.edit" :ref='node.data.key'
                                v-model="node.data.keyt" @blur="handleInputBlur" @keydown.enter="handleInputBlur"
                                size="small" autosize />
                        </div>
                    </el-col>

                    <!-- show the value -->
                    <el-col :span="14">
                        <el-input v-if="node.data.type === 'Param'" v-model="node.data.value" type="textarea"
                            autosize />
                    </el-col>
                </el-row>
                <editParam v-if="!node.data.hide" v-for="nodeChildren in node.children" :node="nodeChildren"
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
                key: '',
                value: '',
                type: 'Param'
            },
            showAddNodeDialog: false,
        };
    },
    methods: {
        addNode(key, value, type) {
            if (!key) key = 'Default Key'
            for (let child of this.node.children) {
                if (child.data.key === key) {
                    this.$message.error('Key Already Exist!');
                    return;
                }
            }
            if (!this.node.children) {
                this.node.children = [];
            }
            this.node.children.unshift({
                data: {
                    key: key,
                    type: type,
                    value: value,
                },
                children: []
            });
            this.$message.success('Node add successfully!');
        },
        removeNode() {
            this.children.splice(this.children.indexOf(this.node), 1);
            this.$message.success('Node removed successfully!');
        },
        focus(key) {
            console.log(key, 'focus')
            let _this = this
            setTimeout(function () {
                _this.$refs[key].focus();
            }, 10)
        },
        handleInputBlur() {
            // 验证输入是否为重复
            if (this.node.data.keyt === this.node.data.key) {
                this.node.data.edit = false;
                return;
            }
            // 验证兄弟节点是否存在重复
            for (let sibling of this.children) {
                if (sibling.data.key === this.node.data.keyt) {
                    this.$message.error('Key Already Exist!');
                    this.node.data.edit = false;
                    return;
                }
            }
            // 输入验证通过，更新节点数据
            if (this.node.data.keyt) {
                this.node.data.key = this.node.data.keyt;
            } else {
                this.$message.warning('Input cannot be empty');
                this.node.data.keyt = this.node.data.key;
            }
            this.node.data.edit = false;
        },
        syncChildrenFold(children, fold) {
            if (!children || children.length === 0) return;
            children.forEach((child) => {
                child.data.hide = fold;
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
        },
    },
    watch: {
        globalFold(newVal) {
            if (newVal !== null) {
                this.node.data.hide = newVal;
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