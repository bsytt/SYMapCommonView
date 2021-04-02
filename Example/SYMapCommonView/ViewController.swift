//
//  ViewController.swift
//  SYMapCommonView
//
//  Created by bsytt on 04/02/2021.
//  Copyright (c) 2021 bsytt. All rights reserved.
//

import UIKit
import SYMapCommonView

let SYWidth = UIScreen.main.bounds.width
let SYHeight = UIScreen.main.bounds.height

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        title = "河南地图"
        initSubview()
    }

    func initSubview() {
        self.view.addSubview(titleLab)
        self.view.addSubview(mapView)
        mapView.clickActionBlock = {[weak self] place in
            print("点击了地图:\(place)")
            self?.titleLab.text = place
        }
        if (self.mapView.seletedAry.count > 0) {
            self.titleLab.text = self.mapView.seletedAry[0]
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    lazy var mapView: SYMapCommonView = {
        let map = SYMapCommonView()
        let scale : CGFloat = (SYWidth-30)/410
        map.transform = CGAffineTransform(scaleX: scale, y: scale)//宽高伸缩比例
        map.frame = CGRect(x: 15, y: 0, width: SYWidth-30, height: SYWidth )
        map.center = CGPoint(x: SYWidth/2 ,y: SYHeight/2);
        map.backgroundColor = UIColor.white
        map.pathFileName = "henanPath.plist"
        map.infoFileName = "henanName.plist"
        map.clickEnable = true
        map.seletedAry = ["南阳"]
        map.lineColor = .white
        return map
    }()
    
    lazy var titleLab: UILabel = {
        let lab = UILabel()
        lab.textColor = .black
        lab.frame = CGRect(x: 0, y: 100, width: UIScreen.main.bounds.width, height: 30)
        lab.textAlignment = .center
        return lab
    }()

}

