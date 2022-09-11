function main(){
    return {
        show: false,
        statusHud: true,
        infoHud: true,
        height: 1080,
        position: {
            'status':{
                top: 0,
                left: 0
            },
            'info':{
                top: 0,
                left: 0,
                height: 0
            }
        },
        elements:{ // Add hud elements here
            // 'microphone':{
            //     progress: null,
            //     name: 'mic',
            //     color: 'white',
            //     icon: 'fa-solid fa-microphone-lines',
            //     show: true,
            //     value: 0.5,
            // },
            'health':{
                progress: null,
                name: 'hp',
                color: '#ef4444',
                icon: 'fa-solid fa-heart',
                show: true,
            },
            'armor':{
                progress: null,
                name: 'ar',
                color: '#3b82f6',
                icon: 'fa-solid fa-shield',
                show: false,
                displayFrom: 0.01, // You can set display from value the status will be hidden
            },
            'hunger':{
                progress: null,
                name: 'hg',
                color: '#f59e0b',
                icon: 'fa-solid fa-pizza-slice',
                show: true,
            },
            'thirst':{
                progress: null,
                name: 'th',
                color: '#06b6d4',
                icon: 'fa-solid fa-droplet',
                show: true,
                value: 0.5,
            },
            'drunk':{
                progress: null,
                name: 'dr',
                color: '#6366f1',
                icon: 'fa-solid fa-wine-bottle',
                show: false,
                displayFrom: 0.01
            }
        },
        info_elements:{
            'money':{
                color:'#22c55e',
                value: 1000,
                icon: 'fa-solid fa-money-bill',
                show: true
            },
            'bank':{
                color:'#f97316',
                value: 1000,
                icon: 'fa-solid fa-credit-card',
                show: true
            },
            'black_money':{
                color:'#ef4444',
                value: 1000,
                icon: 'fa-solid fa-sack-dollar',
                show: true,
            },
            'job':{
                color:'#eab308',
                value: 'Police - Caddet',
                icon: 'fa-solid fa-helmet-safety',
                show: true,
            }
        },
        listen(){
            window.addEventListener('message', (event) => {
                let data = event.data
                switch(data.ui){
                    case 'init':
                        const width  = window.innerWidth || document.documentElement.clientWidth || document.body.clientWidth;
                        const height = window.innerHeight|| document.documentElement.clientHeight|| document.body.clientHeight;
                        this.position.status.top = height * data.data.y - 60
                        this.position.status.left = width * data.data.x
                        this.position.info.top = height * data.data.y - 5
                        this.position.info.left = width * data.data.right_x + 5
                        this.position.info.height = height * data.data.height
                        this.height = height
                        this.show = data.show
                        break;
                    case 'updateStatus':
                        for(let i=0; i<data.data.length; i++){
                            let status = data.data[i]
                            let element = this.elements[status.name]
                            if(element != null){
                                if(element.displayFrom != null){
                                    if(element.displayFrom < status.percent / 100){
                                        element.show = true
                                    }else{
                                        element.show = false
                                    }
                                }
                                element.progress.animate(status.percent / 100)
                            }             
                        }
                        break;
                    case 'updateInfo':
                        for(let i=0; i<data.data.length; i++){
                            let info = data.data[i]
                            let element = this.info_elements[info.name]
                            if(element != null){
                                element.value = info.value
                            }             
                        }
                        break;
                    case 'show':
                        this.statusHud = data.show
                        this.infoHud = data.show
                        break;
                }
            })
        },
        createBar(element){
            element.progress = new ProgressBar.Circle(`.${element.name}`, {
                strokeWidth: 10,
                easing: 'easeInOut',
                duration: 500,
                color: element.color,
                trailColor: 'rgba(6,6,6,0.21332282913165268)',
                trailWidth: 10,
                svgStyle: null
            });
            element.progress.animate(Math.random())
        }
    }
}