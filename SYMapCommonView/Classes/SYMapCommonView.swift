//
//  SYMapCommonView.swift
//  SYMapCommonView
//
//  Created by bsoshy on 2021/4/2.
//

import UIKit

public typealias SYClickActionBlock = (String)->()
open class SYMapCommonView: UIView {
/**
 背景色 默认
 */
    public var backColorDefult : UIColor = UIColor(red: 95.0/255, green: 169.0/255.0, blue: 232.0/255.0, alpha: 1)
/**
 背景色 高亮
 */
    public var backColorHeight : UIColor = UIColor(red: 60.0/255, green: 138.0/255.0, blue: 214.0/255.0, alpha: 1)

/**
 地图上名字 字号
 */
    public var nameFont : UIFont = .systemFont(ofSize: 13)
/**
 地图上名字 颜色
 */
    public var nameColor : UIColor = .white
/**
 边界线 颜色
 */
    public var lineColor : UIColor = .white
/**
 画图资源文件
 */
    public var pathFileName : String!
/**
 子地图在整个地图的位置,子地图的名字,序号等信息资源文件
 */
    public var infoFileName : String!
/**
 选中的模块
 */
    public var seletedAry : [String]! {
        didSet {
            selectAction(seletedAry: seletedAry)
        }
    }
/**
 点击地图功能 开启后关闭设置选中省份功能  默认 false
 */
    public var clickEnable : Bool = false {
        didSet {
            clickEnableMethod()
        }
    }
/**
 点击省份事件 只有当 clickEnable == YES 才响应
 */
    public var clickActionBlock : SYClickActionBlock?
    
/**地图块贝塞尔曲线数组*/
    private lazy var pathAry: [UIBezierPath] = {
        var arr = [UIBezierPath]()
        guard let sourcePath = Bundle.main.path(forResource: pathFileName, ofType: nil) else {
            return []
        }
        arr = NSKeyedUnarchiver.unarchiveObject(withFile: sourcePath) as! [UIBezierPath]
        return arr
    }()
/**地图块贝塞尔曲线颜色数组*/
    private lazy var colorAry: [UIColor] = {
        var arr = [UIColor]()
        for path in self.pathAry {
            let fillColor = backColorDefult
            arr.append(fillColor)
        }
        return arr
    }()
    
/**各个区名字及位置数组*/
    private lazy var textAry: [[String:Any]] = {
        var arr = [[String:Any]]()
        guard let sourcePath = Bundle.main.path(forResource: infoFileName, ofType: nil) else {
            return []
        }
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: sourcePath)) else {
            return []
        }
        arr = NSKeyedUnarchiver.unarchiveObject(with: data as Data) as! [[String : Any]]
        return arr
    }()
/**选中的地图块*/
    private var seletedIdx : Int = 0
/**序号对应的名字*/
    private lazy var nameWithIndexDic: [String:String] = {
        var nameDic = [String:String]()
        for dic in textAry {
            let value = dic["name"]
            let k = dic["index"] as? Int
            let key = String(k ?? 0)
            let str = value as? String
            nameDic[key] = str ?? ""
        }
        return nameDic
    }()
/**名子对应的序号*/
//    private var indexWithNameDic : [String:String]!
    private lazy var indexWithNameDic: [String:String] = {
        var nameDic = [String:String]()
        for dic in textAry {
            let value = dic["name"]
            let k = dic["index"] as? Int
            let key = String(k ?? 0)
            let str = value as? String
            nameDic[key] = str ?? ""
        }
        return nameDic
    }()
//执行一次
    private var isRuned : Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .gray
        clickEnableMethod()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func draw(_ rect: CGRect) {
        // 边线颜色
        let strokeColor = self.lineColor
        for (i,item) in self.pathAry.enumerated() {
            item.miterLimit = 4
            item.lineJoinStyle = .round
            self.colorAry[i].setFill()
            item.fill()
            strokeColor.setStroke()
            item.lineWidth = 1
            item.stroke()
        }
        // 绘制文字
        for item in self.textAry {
            let name = item["name"] as? String
            let rectValue = item["rect"] as? NSValue
            if let name = name,let rectValue = rectValue,name != "" {
                drawText(name: name, rect: rectValue)
            }else {
                print("绘制文字失败")
            }
        }
    }
    
    func drawText(name:String,rect:NSValue) {
        let textRect:CGRect = rect.cgRectValue
        let textContent = name
        let context = UIGraphicsGetCurrentContext()
        let textStyle = NSMutableParagraphStyle()
        textStyle.alignment = .center
        // 省份名字: 字号 颜色 段落样式
        let dic = [NSAttributedString.Key.font:UIFont.systemFont(ofSize: 13),NSAttributedString.Key.foregroundColor:nameColor,NSAttributedString.Key.paragraphStyle:textStyle]
        let textH = textContent.boundingRect(with: CGSize(width: textRect.width, height: CGFloat(Int.max)), options: .usesLineFragmentOrigin, attributes: dic, context: nil).height
        context?.saveGState()
        context?.clip(to: textRect)
        textContent.draw(in: CGRect(x: textRect.minX, y: textRect.minY+(textRect.height-textH)/2, width: textRect.width, height: textH), withAttributes: dic)
        context?.restoreGState()
        
    }
    
    func clickEnableMethod() {
        if !clickEnable {
            if (self.gestureRecognizers?.count ?? 0) > 0 {
                self.gestureRecognizers = []
            }
        }else {
            if (self.gestureRecognizers?.count ?? 0) > 0 {
            }else {
                let click = UITapGestureRecognizer(target: self, action:#selector(click(sender:)))
                self.addGestureRecognizer(click)
            }
        }
    }
    
    func tap(point:CGPoint) {
        //遍历所有市地图块.判断点击的是那一块
        for (i,path) in self.pathAry.enumerated() {
            let isInPath = path.contains(point)
            if isInPath {
                //清除默认选中的颜色,只执行一次即可
                if !isRuned {
                    cleanSelectColor()
                    isRuned = true
                }
                //清除之前选中的颜色
                colorAry[seletedIdx] = backColorDefult
                seletedIdx = i
                //fill当前选中的颜色
                colorAry[seletedIdx] = backColorHeight
                self.setNeedsDisplay()
                let province = nameWithIndexDic["\(seletedIdx+1)"]
                self.clickActionBlock?(province ?? "")
            }
        }
    }
    
    func cleanSelectColor() {
        if seletedAry.isEmpty {
            return
        }
        for name in seletedAry {
            if name.count <= 0{
                return
            }
            let value = indexWithNameDic[name]
            let index = (Int(value ?? "0") ?? 0)-1
            if index < 0 {
                continue
            }
            self.colorAry[index] = self.backColorDefult
        }
    }
    
    func selectAction(seletedAry:[String]) {
        if seletedAry.isEmpty {
            return
        }
        for name in seletedAry {
            if name.count <= 0{
                return
            }
            let value = indexWithNameDic[name]
            let index = (Int(value ?? "0") ?? 0)-1
            if index < 0 {
                continue
            }
            self.colorAry[index] = self.backColorHeight
        }
        self.setNeedsDisplay()
    }
    
    @objc func click(sender:UITapGestureRecognizer) {
        let point = sender.location(in: sender.view)
        tap(point: point)
    }
    
}
