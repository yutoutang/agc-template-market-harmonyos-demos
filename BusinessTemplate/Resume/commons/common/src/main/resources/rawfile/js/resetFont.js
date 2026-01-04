document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener('click', function (e) {
        e.preventDefault();
        document.querySelector(this.getAttribute('href')).scrollIntoView({
            behavior: 'smooth'
        });
    });
});
let e = document.documentElement;

// 动态调整字体大小以适应屏幕宽度
function adjustFontSize() {
    let t = 100 * e.clientWidth / 360;

    document.documentElement.style.fontSize = "".concat(t, "px")

}

// 初始化和窗口大小改变时调整字体大小
adjustFontSize();
window.addEventListener('resize', adjustFontSize);