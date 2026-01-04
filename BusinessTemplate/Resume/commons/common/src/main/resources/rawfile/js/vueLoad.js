const {createApp, ref, reactive} = Vue

createApp({
    setup() {
        let appData = reactive({})
        if (window.appCall) {
            appData = appCall.initWebData() ? JSON.parse(appCall.initWebData()) : {};
        } else {
            appData = {}
        }

        function htmlTestParam() {

        }

        window.htmlTestParam = htmlTestParam
        let showPage = ref(true)
        return {
            appData,
            showPage
        }
    }
}).mount('#app')