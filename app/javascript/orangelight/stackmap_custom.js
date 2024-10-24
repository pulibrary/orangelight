// This class customizes stackmap

export default class StackmapCustom {
    renameButton(){
      const buttonName = document.querySelectorALL(".SMButton.SMsearchbtn > span")
      buttonName.forEach(button => {
        button.innerHtml = "Find on shelf";
      });
    }
}