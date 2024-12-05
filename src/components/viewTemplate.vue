<template>
    <ul>
        <el-form :model="node" ref="form" abel-width="auto">
            <li>
                <el-row :gutter="2" style="padding-bottom: 10px;">
                    <el-col :span="6">
                        <!-- show key -->
                        <div v-if="node.type === 'Map'" style="overflow-wrap: break-word;">
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
                            <span>{{ node.name }}</span>
                        </div>
                        <div v-if="node.type !== 'Map'" style="overflow-wrap: break-word;">
                            <span>{{ node.name }}</span>
                        </div>
                        
                    </el-col>

                    <!-- show the value -->
                    <el-col :span="3">
                        <div v-if="node.type !== 'Map' " class="value-show">{{ node.defaultValue }}</div>
                    </el-col>
                    <el-col :span="3">
                        <div v-if="node.type !== 'Map' " class="value-show">{{ node.allowed }}</div>
                    </el-col>
                    <el-col :span="3">
                        <div v-if="node.type !== 'Map' " class="value-show">{{ node.requiredOnSigning }}</div>
                    </el-col>
                    <el-col :span="3">
                        <div v-if="node.type !== 'Map' " class="value-show">{{ node.scope }}</div>
                    </el-col>
                    <el-col :span="3">
                        <div v-if="node.type !== 'Map' " class="value-show">{{ node.type }}</div>
                    </el-col>
                    <el-col :span="3">
                        <div v-if="node.type !== 'Map' " class="value-show">{{ node.parent }}</div>
                    </el-col>
                </el-row>
                <viewTemplate v-if="!node.hide" v-for="nodeChildren in node.children" :node="nodeChildren"
                    :children="node.children" />
            </li>
        </el-form>
    </ul>
</template>

<script>

export default {
    props: {
        node: {
            type: Object,
            default: {}
        },
        children: {
            type: Array,
            default: []
        }
    }
}
</script>

<style scoped>
svg {
    height: 1em;
    width: 1em;
    color: black;
}
.value-show {
    overflow-wrap: break-word;
    /* border: 1px solid #ccc; */
    background-color: #F2F3F5;
}
</style>